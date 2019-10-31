//
//  InappWebView.swift
//  ViPass
//
//  Created by Ngo Lien on 5/7/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class InappWebView:BaseVC, WKNavigationDelegate {
    var webView:WKWebView!
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var vBar:UIView!
    @IBOutlet weak var vClose:UIView!
    @IBOutlet weak var vLoading:UIActivityIndicatorView!
    
    var url:URL!
   
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default //.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbTitle.text = self.title!
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
        
        guard Utils.isNetworkConnected() else {
            let alert = AlertView.getFromNib(title: "No internet connection.")
            alert.show()
            return
        }
        
        // loading URL :
        let request = URLRequest(url: self.url)
        
        // init and load request in webview.
        self.webView.navigationDelegate = self
        self.webView.load(request)
        if Utils.isPad() {
            self.vLoading.activityIndicatorViewStyle = .whiteLarge
            self.vLoading.color = AppColor.COLOR_TABBAR_ACTIVE
        }
        self.view.bringSubview(toFront: self.vLoading)
    }
    
    @IBAction func ibaClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- WKNavigationDelegate
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.vLoading.stopAnimating()
        let alert = AlertView.getFromNib(title: "Something went wrong!")
        alert.show()
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.vLoading.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.vLoading.stopAnimating()
    }
}


