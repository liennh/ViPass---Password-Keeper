//
//  ClearClipboardView.swift
//  ViPass
//
//  Created by Ngo Lien on 5/4/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class ClearClipboardView:UIView {
    @IBOutlet weak var lbSecond:UILabel!
    @IBOutlet weak var lbContent:UILabel!
    @IBOutlet weak var vLeft:UIView!
    @IBOutlet weak var vRight:UIView!
    
    var timer:Timer!
    var seconds:Int = 60 // seconds == 1 minute
    
    
    /*
     let myCustomView: CustomView = UIView.fromNib()
     or
     let myCustomView: CustomView = .fromNib()
     Refer to https://stackoverflow.com/questions/24857986/load-a-uiview-from-nib-in-swift
     */
    class func getFromNib() -> ClearClipboardView {
        let view:ClearClipboardView = UIView.fromNib()
        let radius:CGFloat = 5.0
        view.layer.cornerRadius = radius
        view.vLeft.layer.cornerRadius = radius
        view.vRight.layer.cornerRadius = radius
        
        // Adjust width of view
        let window = UIApplication.shared.keyWindow
        let screenSize = UIScreen.main.bounds.size
        var frame = view.frame
        frame.origin.x = 16
        if UIDevice.current.screenType == .iPhoneX {
            frame.origin.y = (window?.frame.size.height)! - frame.size.height - 64.0 - 35.0 //175.0
        } else {
            frame.origin.y = (window?.frame.size.height)! - frame.size.height - 64.0
        }
        if Utils.isPad() {
            frame.size.width = 500
            frame.origin.x = (screenSize.width - frame.size.width)/2.0
        } else {
            frame.size.width = screenSize.width - 32
        }
        
        view.frame = frame
        
        view.adjustGUI()
        view.lbSecond.text = "\(view.seconds)s"
        
        view.runTimer()
        return view
    }
    
    @IBAction func ibaClear() {
        UIPasteboard.general.string = ""
        self.dismissView()
    }
    
    func show() {
        let window = UIApplication.shared.keyWindow
        // Animate alpha
        self.alpha = 0.0
        for subview in self.subviews {
            subview.alpha = 0.0
        }
        window?.addSubview(self)
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: UIViewAnimationOptions.transitionCrossDissolve,
                       animations: { [unowned self] in
                        self.alpha = 1.0
                        for subview in self.subviews {
                            subview.alpha = 1.0
                        }
            }, completion: nil)
    }
    
    func dismissView() {
        if self.timer != nil {
            self.timer.invalidate()
            self.timer = nil
        }
        UIView.animate(withDuration: 0.75,
                       delay: 0,
                       options: UIViewAnimationOptions.transitionCrossDissolve,
                       animations: { [unowned self] in
                        self.removeFromSuperview()
        },
                       completion: nil)
    }
    
    func runTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTimer() {
        self.seconds -= 1     //This will decrement(count down)the seconds.
        self.lbSecond.text = "\(seconds)s" //This will update the label.
        if self.seconds == 0 {
            self.ibaClear()
        }
    }
    
    // MARK: Adjust GUI
    private func adjustGUI() {
        // Adjust GUI on different screen sizes
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            // self.adjustOnPhone6()
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            //self.adjustOnPhone6Plus()
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.adjustOnPhone5S()
        } else if UIDevice.current.screenType == .iPhoneX {
            //self.adjustOnPhoneX()
        } else if UIDevice.current.screenType == .iPhone4_4S {
            //self.adjustOnPhone4S()
        }
    }
    
    private func adjustOnPhone5S() {
        self.lbContent.font = UIFont.boldSystemFont(ofSize: 15)
    }
}
