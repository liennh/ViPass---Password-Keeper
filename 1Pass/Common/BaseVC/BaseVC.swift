//
//  BaseVC.swift
//  ViPass
//
//  Created by Ngo Lien on 4/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class BaseVC: UIViewController {
    var loadingSquare:AASquaresLoading?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func loadView() {
        super.loadView()
        let screenSize = UIScreen.main.bounds.size
        var frame = self.view.frame
        frame.size.width = screenSize.width
        frame.size.height = screenSize.height
        self.view.frame = frame
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    
//    func statusbarStyle(_ style: UIStatusBarStyle){
//        UIApplication.shared.statusBarStyle = style
//    }
    
    func setBar(title: String, textColor: UIColor, background: UIColor) {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor]
        self.title = title
        self.navigationController?.navigationBar.barTintColor = background
    }
    
    // MARK: UIButton highlight when tapped
    @IBAction func ibaDefaultButtonTouchDown(sender:UIButton!) {
        // Higlight background color
        sender.titleLabel?.textColor = UIColor.white
        sender.setTitleColor(.white, for: .normal)
        sender.setTitleColor(.white, for: .selected)
        sender.setTitleColor(.white, for: .highlighted)
        sender.backgroundColor = AppColor.COLOR_PURPLE_BUTTON_DOWN
    }
    
    func defaultButtonTouchUp(_ sender:UIButton!) {
        // Higlight background color
        sender.backgroundColor = AppColor.COLOR_PURPLE_BUTTON_DOWN
        UIView.animate(withDuration: 0.5, delay: 0.0, options:[], animations:{
            sender.backgroundColor = AppColor.COLOR_TABBAR_ACTIVE
            let textColor = UIColor.white
            sender.setTitleColor(textColor, for: .normal)
            sender.setTitleColor(textColor, for: .selected)
            sender.setTitleColor(textColor, for: .highlighted)
        }, completion: nil)
    }
    
    func whiteButtonTouchUp(_ sender:UIButton!) {
        // Higlight background color
        sender.backgroundColor = AppColor.COLOR_PURPLE_BUTTON_DOWN
        UIView.animate(withDuration: 0.5, delay: 0.0, options:[], animations:{
            sender.backgroundColor = UIColor.clear
            let textColor = AppColor.COLOR_TABBAR_ACTIVE
            sender.setTitleColor(textColor, for: .normal)
            sender.setTitleColor(textColor, for: .selected)
            sender.setTitleColor(textColor, for: .highlighted)
        }, completion: nil)
    }
    
    @IBAction func ibaGrayButtonTouchDown(sender:UIButton!) {
        // Higlight background color
        sender.backgroundColor = AppColor.COLOR_GRAY_BUTTON_DOWN
        sender.titleLabel?.textColor = UIColor.white
        sender.setTitleColor(.white, for: .normal)
        sender.setTitleColor(.white, for: .selected)
        sender.setTitleColor(.white, for: .highlighted)
    }
    
    func grayButtonTouchUp(_ sender:UIButton!) {
        // Higlight background color
        sender.backgroundColor = AppColor.COLOR_GRAY_BUTTON_DOWN
        sender.titleLabel?.textColor = UIColor.white
        sender.setTitleColor(.white, for: .normal)
        sender.setTitleColor(.white, for: .selected)
        sender.setTitleColor(.white, for: .highlighted)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options:[], animations:{
            sender.backgroundColor = UIColor.clear
            let textColor = AppColor.COLOR_TABBAR_ACTIVE
            sender.titleLabel?.textColor = textColor
            sender.setTitleColor(textColor, for: .normal)
            sender.setTitleColor(textColor, for: .selected)
            sender.setTitleColor(textColor, for: .highlighted)
        }, completion: nil)
    }
    
    @IBAction func ibaBlueButtonTouchDown(sender:UIButton!) {
        // Higlight background color
        sender.titleLabel?.textColor = UIColor.white
        sender.setTitleColor(.white, for: .normal)
        sender.setTitleColor(.white, for: .selected)
        sender.setTitleColor(.white, for: .highlighted)
        sender.backgroundColor = AppColor.COLOR_BLUE_BOLD
    }
    
    func blueButtonTouchUp(_ sender:UIButton!) {
        // Higlight background color
        sender.backgroundColor = AppColor.COLOR_BLUE_BOLD
        UIView.animate(withDuration: 0.5, delay: 0.0, options:[], animations:{
            sender.backgroundColor = UIColor.clear
            let textColor = AppColor.COLOR_BLUE_BOLD
            sender.setTitleColor(textColor, for: .normal)
            sender.setTitleColor(textColor, for: .selected)
            sender.setTitleColor(textColor, for: .highlighted)
        }, completion: nil)
    }
    
    // MARK: Loading animation
    func showLoading() {
        //self.progressHUD = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        if self.loadingSquare == nil {
            self.loadingSquare = AASquaresLoading(target: UIApplication.shared.keyWindow!, size: 40)
        }
        // Customize background
        self.loadingSquare?.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        // Customize color
        self.loadingSquare?.color = AppColor.COLOR_TABBAR_ACTIVE
        // Start loading
        self.loadingSquare?.start()
    }
    
    func hideLoading() {
        //self.progressHUD.hide(animated: true)
        self.loadingSquare?.stop()
    }
}
