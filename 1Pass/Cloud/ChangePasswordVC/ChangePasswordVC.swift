//
//  ChangePasswordVC.swift
//  ViPass
//
//  Created by Ngo Lien on 4/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class ChangePasswordVC: BaseVC {
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var tfEmail:UITextField!
    @IBOutlet weak var tfPassword:UITextField!
    @IBOutlet weak var tfConfirmPassword:UITextField!
    @IBOutlet weak var lbError:UILabel!
    @IBOutlet weak var logo:UIImageView!
    @IBOutlet weak var vForm:UIView!
    @IBOutlet weak var vRules:UIView!
    @IBOutlet weak var btnChange:UIButton!
    @IBOutlet weak var vStatusBar:UIView!
    
    var keyboardHeight:CGFloat = 0.0
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        let screenSize = UIScreen.main.bounds.size
        self.scrollView.contentSize = CGSize(width: screenSize.width, height: 754)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.adjustGUI()
    }
    
    // MARK: IBAction
    @IBAction func ibaChangeMasterPassword(sender:UIButton!) {
        self.view.endEditing(true)
        self.defaultButtonTouchUp(sender)
    }
    
    
    // MARK: Keyboard
    @objc func keyboardWillShow(noti: NSNotification) {
        let userInfo:NSDictionary = noti.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        self.keyboardHeight = keyboardRectangle.height
        // do whatever you want with this keyboard height
        let screenSize = UIScreen.main.bounds.size
        var frame = self.scrollView.frame
        frame.size.height = screenSize.height - self.keyboardHeight
        self.scrollView.frame = frame
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 40), animated: true)
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 134), animated: true)
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: -20), animated: true)
        } else if UIDevice.current.screenType == .iPhoneX {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: -20), animated: true)
        } else {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 20), animated: true)
        }
    }
    
    @objc func keyboardWillHide(noti: NSNotification) {
        let screenSize = UIScreen.main.bounds.size
        var frame = self.scrollView.frame
        frame.size.height = screenSize.height
        self.scrollView.frame = frame
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: -10), animated: true)
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: -20), animated: true)
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: -15), animated: true)
        } else if UIDevice.current.screenType == .iPhoneX {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: -30), animated: true)
        } else {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    // MARK: Private methods
    private func adjustGUI() {
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            // self.adjustOnPhone6()
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            self.adjustOnPhone6Plus()
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.adjustOnPhone5S()
        } else if UIDevice.current.screenType == .iPhoneX {
            self.adjustOnPhoneX()
        } else if UIDevice.current.screenType == .iPhone4_4S {
            //self.adjustOnPhone4S()
        }
    }
    
    private func adjustOnPhoneX() {
        self.vStatusBar.increaseHeight(value: 24)
    }
    
    private func adjustOnPhone6Plus() {
        // Do nothing
    }
    
    private func adjustOnPhone5S() {
        //self.lbTitle.font = UIFont.boldSystemFont(ofSize: 27)
        self.logo.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.logo.moveUp(distance: 20)
        self.vForm.moveUp(distance: 20)
        self.vRules.moveUp(distance: 20)
    }
    
}
