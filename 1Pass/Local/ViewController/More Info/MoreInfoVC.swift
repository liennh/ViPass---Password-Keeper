//
//  MoreInfoVC.swift
//  1Pass
//
//  Created by Ngo Lien on 7/28/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import UIKit

class MoreInfoVC: UIViewController {
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var vBar:UIView!
    @IBOutlet weak var vClose:UIView!
    @IBOutlet weak var btnInfo:UIButton!
    @IBOutlet weak var scrollView:UIScrollView!
    
    var question: String!
    var info:String!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default //.lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.lbTitle.font = UIFont.boldSystemFont(ofSize: 27.0)
        } else if UIDevice.current.screenType == .iPhoneX {
            var frame = self.vBar.frame
            frame.origin.y += 30
            // frame.size.height = 145.0
            self.vBar.frame = frame
            
            let screenSize = UIScreen.main.bounds.size
            
            frame = self.scrollView.frame
            frame.origin.y = self.vBar.frame.origin.y + self.vBar.frame.size.height
            frame.size.height = screenSize.height - frame.origin.y - 44
            self.scrollView.frame = frame
        }
        
        self.lbTitle.text = self.question
        self.btnInfo.setTitle(self.info, for: .normal)
        
        // Calculate height of title
        let fontLight = UIFont.systemFont(ofSize: 18.0, weight: .regular)
        let width = self.scrollView.frame.size.width - 32 // (16 + 16)
        let height = self.info.heightWithConstrainedWidth(width, font: fontLight)
        
        var frame = self.btnInfo.frame
        frame.origin.y = 30
        frame.size.height = height! + 50
        self.btnInfo.frame = frame
        let screenSize = UIScreen.main.bounds.size
        self.scrollView.contentSize = CGSize(width: screenSize.width, height: frame.size.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ibaClose() {
        self.dismiss(animated: true, completion: nil)
    }
}
