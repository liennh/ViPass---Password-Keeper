//
//  Feedback.swift
//  ViPass
//
//  Created by Ngo Lien on 5/8/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class Feedback:FeedbackBase  {
    @IBOutlet weak var iconRating:UIImageView!
    @IBOutlet weak var iconMail:UIImageView!
    @IBOutlet weak var iconTwitter:UIImageView!
    @IBOutlet weak var iconFacebook:UIImageView!
    
    @IBOutlet weak var view1:UIView!
    @IBOutlet weak var view2:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.iconRating.image = self.iconRating.image?.tint(AppColor.COLOR_TABBAR_ACTIVE)
        self.iconMail.image = self.iconMail.image?.tint(AppColor.COLOR_TABBAR_ACTIVE)
        self.iconTwitter.image = self.iconTwitter.image?.tint(AppColor.COLOR_TABBAR_ACTIVE)
        self.iconFacebook.image = self.iconFacebook.image?.tint(AppColor.COLOR_TABBAR_ACTIVE)
    }
    
    @IBAction func ibaClose(sender:UIButton!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ibaWriteReview(sender:UIButton!) {
        self.grayButtonTouchUp(sender)
        if let reviewURL = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id\(AppConfig.Apple_ID)?mt=8"), UIApplication.shared.canOpenURL(reviewURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(reviewURL)
            }
        }
    }
    
    @IBAction func ibaShareOnTwitter(sender:UIButton!) {
        self.grayButtonTouchUp(sender)
        self.doShareOnFBTwitter(sender)
    }
    
    @IBAction func ibaShareOnFacebook(sender:UIButton!) {
        self.grayButtonTouchUp(sender)
        self.doShareOnFBTwitter(sender)
    }
    
    func doShareOnFBTwitter(_ sender:UIButton!) {
        let text = "Love this app. Recommend you to try it."
        let website = URL(string: "https://1pass.vn")
        let shares = [text, website!] as [Any]
        let activityVC = UIActivityViewController(activityItems: shares , applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.postToWeibo,
                                                        UIActivityType.message,
                                                        UIActivityType.mail,
                                                        UIActivityType.print,
                                                        UIActivityType.copyToPasteboard,
                                                        UIActivityType.assignToContact,
                                                        UIActivityType.saveToCameraRoll,
                                                        UIActivityType.addToReadingList,
                                                        UIActivityType.postToFlickr,
                                                        UIActivityType.postToVimeo,
                                                        UIActivityType.postToTencentWeibo,
                                                        UIActivityType.airDrop]
        
        
        //activityViewController.popoverPresentationController?.sourceView = self.view
        if Utils.isPad() {
            if let popOver = activityVC.popoverPresentationController {
                popOver.sourceView = sender
                //popOver.sourceRect =
                //popOver.barButtonItem
                self.present(activityVC, animated: true, completion: nil)
            }
        } else {
           self.present(activityVC, animated: true, completion: nil)
        }
    }
}
