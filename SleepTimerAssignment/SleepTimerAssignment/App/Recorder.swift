//
//  Recorder.swift
//  SleepTimerAssignment
//
//  Created by Mykola Aleshchenko on 19.05.2020.
//  Copyright © 2020 Mykola Aleshchenko. All rights reserved.
//

import Foundation
import AVFoundation
import os.log

final class Recorder {
    private var audioRecorder: AVAudioRecorder!
    private var fileExtension = "aac"
    
    private var isRecordingTurnedOff: Bool = false
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRouteChange(_:)),
                                               name: AVAudioSession.interruptionNotification, object: audioRecorder)
    }
    
    func record() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true)
            DispatchQueue.main.async {
                let audioFilename = self.getDocumentsDirectory().appendingPathComponent(Date().fullDateString()).appendingPathExtension(self.fileExtension)
                
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 12000,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
                ]
                
                do {
                    self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                    self.audioRecorder.record()
                } catch {
                    os_log("Failed to create recoding session")
                }
            }
        } catch {
            os_log("Failed to start recording")
        }
    }
    
    func toggle() {
        if isRecordingTurnedOff {
            return
        }
        
        if audioRecorder.isRecording {
            audioRecorder.pause()
        } else {
            audioRecorder.record()
        }
    }
    
    func stopForTheSession()  {
        isRecordingTurnedOff = !isRecordingTurnedOff
    }
    
    func stopRecording() {
        if let recorder = self.audioRecorder {
            recorder.stop()
        }
    }
    
    // MARKK - Notifications
    
    @objc func sessionRouteChange(_ notification: Notification) {
        toggle()
    }
    
    // MARK: - Miscellaneous
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
