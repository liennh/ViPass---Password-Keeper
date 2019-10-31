//
//  FeedbackBase.swift
//  ViPass
//
//  Created by Ngo Lien on 5/9/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class FeedbackBase:BaseVC, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var lbText:UILabel!
    @IBOutlet weak var vBar:UIView!
    @IBOutlet weak var lbTitle:UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default //.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.adjustGUI()
    }
    
    @IBAction func ibaContactTeam(sender:UIButton!) {
        self.grayButtonTouchUp(sender)
        guard MFMailComposeViewController.canSendMail() else {
            let alert = AlertView.getFromNib(title: "Mail services are not available.")
            alert.show()
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients(["info@1pass.vn"])
        composeVC.setSubject("Feedback about \(AppConfig.App_Name)")
        composeVC.setMessageBody("", isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        switch result {
        case .sent:
            GoogleWearAlert.showAlert(title: "Sent!", .success)
        case .saved:
            GoogleWearAlert.showAlert(title: "Saved!", .success)
        case .failed:
            GoogleWearAlert.showAlert(title: "Failed!", .success)
        default:
            let _ = 1
        }
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func ibaGrayButtonTouchDown(sender:UIButton!) {
        // Higlight background color
        super.ibaGrayButtonTouchDown(sender:sender)
        let parent = sender.superview
        for sub in (parent?.subviews)! {
            if sub is UIImageView {
                (sub as! UIImageView).image = (sub as! UIImageView).image?.tint(UIColor.white)
                parent?.bringSubview(toFront: sub)
            }
        }
    }
    
    override func grayButtonTouchUp(_ sender:UIButton!) {
        // Higlight background color
        super.grayButtonTouchUp(sender)
        let parent = sender.superview
        for sub in (parent?.subviews)! {
            if sub is UIImageView {
                (sub as! UIImageView).image = (sub as! UIImageView).image?.tint(AppColor.COLOR_TABBAR_ACTIVE)
                parent?.sendSubview(toBack: sub)
            }
        }
    }
    
    // MARK: Private methods
    private func adjustGUI() {
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            // self.adjustOnPhone6()
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            // self.adjustOnPhone6Plus()
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.adjustOnPhone5S()
        } else if UIDevice.current.screenType == .iPhoneX {
            self.adjustOnPhoneX()
        } else if UIDevice.current.screenType == .iPhone4_4S {
            //self.adjustOnPhone4S()
        }
    }
    
    private func adjustOnPhoneX() {
        self.vBar.increaseHeight(value: 19)
    }
    
    private func adjustOnPhone5S() {
        self.lbText.font = UIFont.systemFont(ofSize: 16)
        self.lbTitle.font = UIFont.boldSystemFont(ofSize: 20)
//        for sub in self.vBar.subviews {
//            sub.moveDown(distance: 10)
//        }
    }
}
