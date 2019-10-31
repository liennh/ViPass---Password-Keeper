//
//  LocalLoginVC.swift
//  ViPass
//
//  Created by Ngo Lien on 4/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class UnlockVC: BaseVC, UITextFieldDelegate {
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var tfPassword:UITextField!
    @IBOutlet weak var lbError:UILabel!
    @IBOutlet weak var iconLock:UIImageView!
    @IBOutlet weak var vStatusBar:UIView!
    @IBOutlet weak var vForm:UIView!
    @IBOutlet weak var vField:UIView!
    @IBOutlet weak var btnUnlock:UIButton!
    @IBOutlet weak var vLoading:UIActivityIndicatorView!
    
    var keyboardHeight:CGFloat = 0.0
    var credentials:[String:Any]?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        let screenSize = UIScreen.main.bounds.size
        self.scrollView.contentSize = CGSize(width: screenSize.width, height: 759)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.adjustGUI()
        self.tfPassword.becomeFirstResponder()
        self.scrollView.isScrollEnabled = false
        
        // Clear Clipboard
        UIPasteboard.general.string = ""
    }
    
    // MARK: IBAction
    @IBAction func ibaUnlock(sender:UIButton!) {
        self.view.endEditing(true)
       // self.defaultButtonTouchUp(sender)
        self.doUnlock()
    }
    
    func doUnlock() {
        guard self.validateInputForm() else {
            return
        }
        self.showLoading()
        
        if (Utils.currentSyncMethod() == SyncMethod.vipass) ||
           (Utils.currentSyncMethod() == SyncMethod.custom) {
            self.perform(#selector(unlockViPass), with: nil, afterDelay: 0.5)
        } else {
            self.perform(#selector(unlock), with: nil, afterDelay: 0.5)
        }
    }
    
    // Used when method sync is NOT "vipass". Means: none, dropbox, googledrive, onedrive...
    @objc private func unlock() {
        let username = AppConfig.local_username
        let password = self.tfPassword.text ?? ""
        let currentUser = User(username: username, password: password)
        Global.shared.currentUser = currentUser
        
        // Get from Keychain
        guard let secretKey = Utils.getSecretKey() else {
            self.showErrorInvalidPassword()
            return
        }
        
        DDLog("getSecretKey: \(secretKey)")
        
        let enc_ak = self.credentials![Keys.enc_ak] as! [UInt8]
        // Decrypt enc_ak + enc_pk
        let aesMasterKey = AppEncryptor.getMasterKey(password: password, secretKey: secretKey)
        
        guard aesMasterKey != nil else {
            self.lbError.text = "Cannot generate master key."
            self.lbError.isHidden = false
            self.makeRed()
            self.hideLoading()
            return
        }
        currentUser.aesMasterKey = aesMasterKey
        
        // Decrypt credentials
        guard let accountKey = AppEncryptor.decryptAES256(cipheredBytes:enc_ak, key:aesMasterKey!) else {
            self.showErrorInvalidPassword()
            return
        }
        
        // Update current User
        currentUser.accountKey = accountKey
        currentUser.secretKey = secretKey
        
        UIApplication.shared.endIgnoringInteractionEvents()
        self.hideLoading()
        
        do {
            DataStore.configureMigration()
            let _ = try Realm()
            // show main screen
            (UIApplication.shared.delegate as! AppDelegate).showLocalMainVC()
        } catch {
            self.lbError.text = "Cannot open database."
            self.lbError.isHidden = false
            self.makeRed()
        }
    }
    
    @objc private func unlockViPass() {
        let username = self.credentials![Keys.i] as! String
        let password = self.tfPassword.text
        let currentUser = User(username: username, password: password)
        Global.shared.currentUser = currentUser
        
        // Get from Keychain
        guard let secretKey = Utils.getSecretKey() else {
            self.showErrorInvalidPassword()
            return
        }
        
        DDLog("getSecretKey: \(secretKey)")
        
        let enc_ssk = self.credentials![Keys.enc_ssk] as! [UInt8]
        let enc_ak = self.credentials![Keys.enc_ak] as! [UInt8]
        
//        let enc_pk = self.credentials![Keys.enc_pk] as! [UInt8]
//        let pubKey = self.credentials![Keys.pubKey] as! [UInt8]
        
        // Decrypt enc_ak + enc_pk
        let aesMasterKey = AppEncryptor.getMasterKey(password: password!, secretKey: secretKey)
        
        guard aesMasterKey != nil else {
            self.lbError.text = "Cannot generate master key."
            self.lbError.isHidden = false
            self.makeRed()
            self.hideLoading()
            return
        }
        currentUser.aesMasterKey = aesMasterKey
        
        // Decrypt credentials
        guard let sessionKey = AppEncryptor.decryptAES256(cipheredBytes:enc_ssk, key:aesMasterKey!) else {
            self.showErrorInvalidPassword()
            return
        }
        guard let accountKey = AppEncryptor.decryptAES256(cipheredBytes:enc_ak, key:aesMasterKey!) else {
            self.showErrorInvalidPassword()
            return
        }
        /*guard let privateKey = AppEncryptor.decryptAES256(cipheredBytes:enc_pk, key:aesMasterKey!) else {
            self.showErrorInvalidPassword()
            return
        }*/
        
        // Update current User
        currentUser.sessionKey = sessionKey
        currentUser.accountKey = accountKey
        currentUser.secretKey = secretKey
        
//        currentUser.privateKey = privateKey
//        currentUser.publicKey = pubKey
        
        UIApplication.shared.endIgnoringInteractionEvents()
        self.hideLoading()
        
        do {
            DataStore.configureMigration()
            let _ = try Realm()
            // show main screen
            (UIApplication.shared.delegate as! AppDelegate).showCloudMainVC()
        } catch {
            self.lbError.text = "Cannot open database."
            self.lbError.isHidden = false
            self.makeRed()
        }
    }
    
    func showErrorInvalidPassword() {
        self.lbError.text = "Invalid master password."
        self.lbError.isHidden = false
        self.makeRed()
        self.hideLoading()
    }
    
    override func hideLoading() {
        self.iconLock.isHidden = false
       // self.vLoading.isHidden = true
        self.vLoading.stopAnimating()
       // self.btnUnlock.superview?.bringSubview(toFront: self.iconLock)
       // self.btnUnlock.superview?.bringSubview(toFront: self.btnUnlock)
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    override func showLoading() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.iconLock.isHidden = true
       // self.btnUnlock.superview?.bringSubview(toFront: self.vLoading)
        self.vLoading.isHidden = false
        self.vLoading.startAnimating()
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
        if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
           // self.scrollView.setContentOffset(CGPoint(x: 0, y: 70), animated: true)
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            // Do nothing
        } else if UIDevice.current.screenType == .iPhoneX {
            // Do nothing
        } else {
            //self.scrollView.setContentOffset(CGPoint(x: 0, y: 20), animated: true)
            self.scrollView.isScrollEnabled = false
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
            //self.scrollView.setContentOffset(CGPoint(x: 0, y: -20), animated: true)
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            //self.scrollView.setContentOffset(CGPoint(x: 0, y: -20), animated: true)
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            // Do nothing
        } else if UIDevice.current.screenType == .iPhoneX {
            // Do nothing
        } else {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
        
    }
    
    // MARK: Private methods
    private func adjustGUI() {
        self.vField.layer.cornerRadius = Constant.Button_Corner_Radius
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
        self.vStatusBar.increaseHeight(value: 24)
        self.vForm.moveDown(distance: 70)
    }
    
    private func adjustOnPhone5S() {
        var frame = self.vForm.frame
        frame.origin.x = 0
        frame.origin.y -= 70
        frame.size.width = self.view.frame.size.width
        self.vForm.frame = frame
        self.tfPassword.font = UIFont.systemFont(ofSize: 17)
    }
    
    private func validateInputForm() -> Bool {
        let password = self.tfPassword.text ?? ""
        guard !password.isEmpty else {
            self.lbError.text = "Please input master password."
            self.lbError.isHidden = false
            self.makeRed()
            return false
        }
        return true
    }
    
    func makeRed() {
        self.vField.layer.borderColor = UIColor.red.cgColor
        self.vField.layer.borderWidth = 1
    }
    
    func removeRed() {
        //self.vField.layer.borderColor = UIColor.red.cgColor
        self.vField.layer.borderWidth = 0
    }
    
    // MARK: UITextField
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        self.lbError.isHidden = true
        self.lbError.text = ""
        self.removeRed()
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.ibaUnlock(sender: self.btnUnlock)
        return true
    }
    
}
