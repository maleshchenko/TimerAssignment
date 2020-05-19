//
//  SleepTimerViewModel.swift
//  SleepTimerAssignment
//
//  Created by Mykola Aleshchenko on 17.05.2020.
//  Copyright © 2020 Mykola Aleshchenko. All rights reserved.
//

import SwiftUI
import Combine

final class SleepTimerViewModel: ObservableObject {
    
    enum AppState: String {
        case idle
        case playing
        case recording
        case paused
        case alarm
    }
    
    @Published private(set) var appState = AppState.idle
    @Published private(set) var isRecordingAvailable = true
        
    let timerOptions = [0, 1, 5, 10, 15, 20]
    
    private var sleepTimeRemaining = 0
    private var alarmTimeRemaining = 0
    
    private lazy var player = Player()
    private lazy var recorder = Recorder()
        
    func description(_ timerOption: Int) -> String {
        return timerOption == 0 ? "Off" : "\(timerOption) min"
    }
    
    private var sleepTimer: AnyCancellable?
    private var alarmTimer: AnyCancellable?
    
    // MARK: - Timers
    
    func startTimers(timerOption: Int, alarmTime: Date) {
        sleepTimeRemaining = timerOption * 60
        alarmTimeRemaining = -Date.timeDifference(startDate: alarmTime)
        
        NotificationHelper().scheduleNotification(after: alarmTimeRemaining)
        proceed()
        player.playSoundEffect()
        
        self.sleepTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            .sink { _ in
                self.sleepTimeRemaining -= 1
                if self.sleepTimeRemaining == 0 {
                    self.sleepTimer?.cancel()
                    self.startRecording()
                }
        }
        
        self.alarmTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            .sink { _ in
                self.alarmTimeRemaining -= 1
                if self.alarmTimeRemaining == 0 {
                    self.alarmTimer?.cancel()
                }
        }
    }
    
    // MARK: - App states
    
    var isStopped: Bool {
        return appState == .idle || appState == .paused
    }
    
    func proceed() {
        switch appState {
        case .idle:
            appState = .playing
        case .playing:
            appState = .paused
            player.toggle()
        case .recording:
            appState = .paused
            recorder.toggle()
        case .alarm:
            appState = .idle
        case .paused:
            if sleepTimeRemaining == 0 && isRecordingAvailable {
                appState = .recording
                recorder.toggle()
            } else {
                appState = .playing
                player.toggle()
            }
        }
    }
    
    // MARK: - Actions
    
    func switchRecordingOff() {
        // the app will keep playing the sound effect in this case
        isRecordingAvailable = false
        recorder.stopForTheSession()
    }
    
    private func startRecording() {
        if isRecordingAvailable && appState != .paused {
            appState = .recording
            player.stop()
            recorder.record()
        }
    }
    
    private func stopRecording() {
        recorder.stopRecording()
    }
    
    func startAlarm() {
        appState = .alarm
        recorder.stopRecording()
        player.playAlarmSound()
    }
    
    func stopAlarm() {
        didFinishFlow()
    }
    
    func didFinishFlow() {
        player.stop()
        appState = .idle
        isRecordingAvailable = true
    }
}
