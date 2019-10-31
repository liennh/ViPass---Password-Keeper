//
//  HowItWorks.swift
//  ViPass
//
//  Created by Ngo Lien on 5/7/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class HowItWorks:BaseVC {
    var webView:WKWebView!
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var vBar:UIView!
    @IBOutlet weak var vClose:UIView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default //.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Adjust GUI
        if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.lbTitle.font = UIFont.boldSystemFont(ofSize: 27.0)
        } else if UIDevice.current.screenType == .iPhoneX {
            var frame = self.vBar.frame
            frame.origin.y += 30
           // frame.size.height = 145.0
            self.vBar.frame = frame
        }
        
        let webConfiguration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
        self.view.addSubview(self.webView)
        
        var frame = self.webView.frame
        frame.origin.y = self.vBar.frame.size.height + self.vBar.frame.origin.y
        frame.size.width = self.view.frame.size.width
        frame.size.height = UIScreen.main.bounds.size.height - frame.origin.y
        self.webView.frame = frame
        
        let htmlFile = Bundle.main.path(forResource: "HowItWorks", ofType: "html")
        let html = try! String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        self.webView.loadHTMLString(html, baseURL: nil)
    }
    
    @IBAction func ibaClose() {
        self.dismiss(animated: true, completion: nil)
    }
}


