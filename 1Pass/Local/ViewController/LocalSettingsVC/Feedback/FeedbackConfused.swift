//
//  FeedbackConfused.swift
//  ViPass
//
//  Created by Ngo Lien on 5/9/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class FeedbackConfused:FeedbackBase {
    @IBOutlet weak var iconGuide:UIImageView!
    @IBOutlet weak var iconMail:UIImageView!
    @IBOutlet weak var view1:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.iconGuide.image = self.iconGuide.image?.tint(AppColor.COLOR_TABBAR_ACTIVE)
        self.iconMail.image = self.iconMail.image?.tint(AppColor.COLOR_TABBAR_ACTIVE)
        
        // Adjust GUI on Pad
        if Utils.isPad() {
            let screenSize = UIScreen.main.bounds.size
            var frame = self.view1.frame
            frame.size.width = 450
            frame.origin.x = (screenSize.width - frame.size.width)/2.0
            frame.origin.y += 100
            self.view1.frame = frame
        }
    }
    
    @IBAction func ibaClose(sender:UIButton!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ibaGettingStarted(sender:UIButton!) {
        self.grayButtonTouchUp(sender)
        let vc = InappWebView(nibName: "InappWebView", bundle: nil)
        vc.title = "Security White Paper"
        let url = URL(string: AppConfig.URL_White_Paper)
        vc.url = url
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
}
