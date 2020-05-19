//
//  Player.swift
//  SleepTimerAssignment
//
//  Created by Mykola Aleshchenko on 18.05.2020.
//  Copyright © 2020 Mykola Aleshchenko. All rights reserved.
//

import Foundation
import AVFoundation
import os.log

final class Player: NSObject {
    private let soundFileName = "nature"
    private let alarmFileName = "alarm"
    private var fileExtension = "m4a"
    
    private var player: AVAudioPlayer!
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRouteChange(_:)),
                                               name: AVAudioSession.interruptionNotification, object: player)
    }
    
    private func play(fileName: String) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: fileExtension) else {
            os_log("File not found: %{public}@", fileName)
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
        } catch {
            os_log("Player initialization error")
        }
        
        player.play()
    }
    
    func playSoundEffect() {
        play(fileName: soundFileName)
    }
    
    func playAlarmSound() {
        play(fileName: alarmFileName)
    }
    
    func toggle() {
        if let player = self.player {
            if player.isPlaying {
                player.pause()
            } else {
                player.play()
            }
        }
    }
    
    func stop() {
        if let player = self.player {
            player.stop()
        }
    }
    
    // MARK: - Notifications
    
    @objc func sessionRouteChange(_ notification: Notification) {
        toggle()
    }
}
