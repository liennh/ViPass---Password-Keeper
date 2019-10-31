//
//  TimerApplication.swift
//  1Pass
//
//  Created by Ngo Lien on 7/19/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//
// Refer to: https://blog.gaelfoppolo.com/detecting-user-inactivity-in-ios-application-684b0eeeef5b

import UIKit

class TimerApplication: UIApplication {
    
    // the timeout in seconds, after which should perform custom actions
    // such as disconnecting the user
    private var timeoutInSeconds: TimeInterval {
        // n minutes
        let autoLockAfter = Utils.getSettingsAutoLockApp()
        return (Double(autoLockAfter) * 60)
    }
    
    private var idleTimer: Timer?
    
    // resent the timer because there was user interaction
    func resetIdleTimer() {
        if let idleTimer = idleTimer {
            idleTimer.invalidate()
        }
        
        idleTimer = Timer.scheduledTimer(timeInterval: timeoutInSeconds,
                                         target: self,
                                         selector: #selector(TimerApplication.timeHasExceeded),
                                         userInfo: nil,
                                         repeats: false
        )
    }
    
    // if the timer reaches the limit as defined in timeoutInSeconds, post this notification
    @objc private func timeHasExceeded() {
        NotificationCenter.default.post(name: .appTimeout,
                                        object: nil
        )
    }
    
    override func sendEvent(_ event: UIEvent) {
        
        super.sendEvent(event)
        
        if idleTimer != nil {
            self.resetIdleTimer()
        }
        
        if let touches = event.allTouches {
            for touch in touches where touch.phase == UITouchPhase.began {
                self.resetIdleTimer()
            }
        }
    }
}
