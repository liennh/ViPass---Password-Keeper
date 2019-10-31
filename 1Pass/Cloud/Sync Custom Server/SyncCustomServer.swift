//
//  LoginVC.swift
//  ViPass
//
//  Created by Ngo Lien on 4/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift
import RealmSwift

class SyncCustomServer: BaseVC, UITextFieldDelegate {
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var tfCustomURL:UITextField!
    @IBOutlet weak var tfApiKey:UITextField!
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var lbError:UILabel!
    @IBOutlet weak var vForm:UIView!
    @IBOutlet weak var iconQuestion:UIImageView!
    @IBOutlet weak var vQuestion:UIView!
    @IBOutlet weak var vRules:UIView!
    @IBOutlet weak var btnContinue:UIButton!
    @IBOutlet weak var vStatusBar:UIView!
    @IBOutlet weak var vLoading:UIActivityIndicatorView!
    
    var loginStep:Int = 1
    
    var keyboardHeight:CGFloat = 0.0
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default //.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        let screenSize = UIScreen.main.bounds.size
        self.scrollView.contentSize = CGSize(width: screenSize.width, height: 725)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.adjustGUI()
    }
    
    override func showLoading() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.vLoading.startAnimating()
        self.btnContinue.superview?.bringSubview(toFront: self.vLoading)
        self.btnContinue.setTitle("Setting Up...", for: .normal)
    }
    
    override func hideLoading() {
        self.vLoading.stopAnimating()
        self.btnContinue.superview?.bringSubview(toFront: self.btnContinue)
        self.btnContinue.setTitle("Continue", for: .normal)
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    @IBAction func ibaCancel(button:UIButton!) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: IBAction - ibaContinue
    @IBAction func ibaContinue(sender:UIButton!) {
        self.view.endEditing(true)
        self.defaultButtonTouchUp(sender)
        
        guard self.validateInputForm() else {
            return
        }
        
        // Set temporary data
        Global.shared.customURL = self.tfCustomURL.text!
        Global.shared.customApiKey = self.tfApiKey.text!
       
        // Show Login
        var vc:LoginVC?
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            vc = LoginVC(nibName: "LoginVC", bundle: nil)
        case .pad:
            vc = LoginVC(nibName: "LoginPAD", bundle: nil)
        default: break;
        }
        vc!.mode = SyncMethod.custom
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func ibaShowMoreInfo() {
        let vc = MoreInfoVC(nibName: "MoreInfoVC", bundle: nil)
        vc.question = "Sync with Custom Server"
        vc.info = """
        Our server is open source. So you can pull the source code to setup your own server then point the URL to it.
        
        + Custom Server URL must be HTTPS for secure connection.
        
        + API Key must be at least 10 characters.
        """
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: Keyboard
    @objc func keyboardWillShow(noti: NSNotification) {
        if Utils.isPad() {
            return
        }
        
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
            //self.scrollView.setContentOffset(CGPoint(x: 0, y: 45), animated: true)
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 80), animated: true)
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            //self.scrollView.setContentOffset(CGPoint(x: 0, y: 10), animated: true)
        } else if UIDevice.current.screenType == .iPhoneX {
           // self.scrollView.setContentOffset(CGPoint(x: 0, y: 1), animated: true)
        } else {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 20), animated: true)
        }
    }
    
    @objc func keyboardWillHide(noti: NSNotification) {
        if Utils.isPad() {
            return
        }
        
        let screenSize = UIScreen.main.bounds.size
        var frame = self.scrollView.frame
        frame.size.height = screenSize.height
        self.scrollView.frame = frame
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            //self.scrollView.setContentOffset(CGPoint(x: 0, y: -10), animated: true)
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            //self.scrollView.setContentOffset(CGPoint(x: 0, y: -15), animated: true)
        } else if UIDevice.current.screenType == .iPhoneX {
           // self.scrollView.setContentOffset(CGPoint(x: 0, y: -30), animated: true)
        } else {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    // MARK: Private methods
    private func adjustGUI() {
        self.iconQuestion.image = self.iconQuestion.image?.tint(UIColor.black)
        self.btnContinue.layer.cornerRadius = Constant.Button_Corner_Radius
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
             self.adjustOnPhone6()
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
             self.adjustOnPhone6Plus()
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.adjustOnPhone5S()
        } else if UIDevice.current.screenType == .iPhoneX {
            self.adjustOnPhoneX()
        } else if Utils.isPad() {
            //self.adjustOnPad()
        }
    }
    
    private func adjustOnPad() {
        let screenSize = UIScreen.main.bounds
        var frame = self.vForm.frame
        frame.size.width = screenSize.width - 349 //450
        frame.origin.x = (screenSize.width - frame.size.width)/2.0
        frame.origin.y += 100
        self.vForm.frame = frame
        
        frame = self.vQuestion.frame
        frame.origin.x = (screenSize.width - frame.size.width)/2.0
        self.vQuestion.frame = frame
        
        self.scrollView.isScrollEnabled = false
    }
    
    private func adjustOnPhone6() {
        self.scrollView.isScrollEnabled = false
    }
    
    private func adjustOnPhone6Plus() {
        self.scrollView.isScrollEnabled = false
    }
    
    private func adjustOnPhoneX() {
        self.vStatusBar.increaseHeight(value: 24)
        self.scrollView.isScrollEnabled = false
    }
    
    private func adjustOnPhone5S() {
        self.lbTitle.font = UIFont.boldSystemFont(ofSize: 27)
        self.vForm.moveUp(distance: 20)
        self.lbError.moveDown(distance: 10)
    }
    
    private func validateInputForm() -> Bool {
        let url = self.tfCustomURL.text ?? ""
        let apiKey = self.tfApiKey.text ?? ""
       
        guard !url.isEmpty else {
            self.lbError.text = "Please input custom server URL."
            self.lbError.isHidden = false
            return false
        }
        
        guard url.isValidURL else {
            self.lbError.text = "Invalid URL."
            self.lbError.isHidden = false
            return false
        }
        
        guard url.contains("https") else {
            self.lbError.text = "URL must begin with https."
            self.lbError.isHidden = false
            return false
        }
        
        guard !apiKey.isEmpty else {
            self.lbError.text = "Please input API key."
            self.lbError.isHidden = false
            return false
        }
        
        guard apiKey.count >= 10 else {
            self.lbError.text = "API key must be at least 10 characters."
            self.lbError.isHidden = false
            return false
        }
        
        guard apiKey.count <= 64 else {
            self.lbError.text = "API key must be in range of 10 to 64 characters."
            self.lbError.isHidden = false
            return false
        }
        
        guard !apiKey.hasWhiteSpace() else {
            self.lbError.text = "API key must not contain whitespace."
            self.lbError.isHidden = false
            return false
        }
        
        return true
    }
    
    // MARK: UITextField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false // Prevent whitespace from url and API Key
        } else {
            return true
        }
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        self.lbError.isHidden = true
        self.lbError.text = ""
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.ibaContinue(sender: self.btnContinue)
        return true
    }
    
}
