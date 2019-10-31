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

class SyncCustomServer2: BaseVC, UITextFieldDelegate {
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var tfCustomURL:UITextField!
    @IBOutlet weak var tfApiKey:UITextField!
    @IBOutlet weak var tfUsername:UITextField!
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var lbError:UILabel!
    @IBOutlet weak var vForm:UIView!
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
        self.btnContinue.setTitle("Signing Up...", for: .normal)
    }
    
    override func hideLoading() {
        self.vLoading.stopAnimating()
        self.btnContinue.superview?.bringSubview(toFront: self.btnContinue)
        self.btnContinue.setTitle("Continue", for: .normal)
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    @IBAction func ibaCancel(button:UIButton!) {
        self.view.endEditing(true)
        if Utils.isPad() {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
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
       
        self.tfUsername.text = self.tfUsername.text?.lowercased()
        self.showLoading()
        
        self.perform(#selector(doSignUp), with: nil, afterDelay: 0.5)
    }
    
    @objc private func doSignUp() {
        let localUser = Global.shared.currentUser
        let newUser = User()
        newUser.username = self.tfUsername.text!
        newUser.masterPassword = localUser?.masterPassword
        newUser.secretKey = localUser?.secretKey //UUID().uuidString
        newUser.accountKey = localUser?.accountKey
        
        guard let params = Params.forSignUp(user:newUser) else {
            Utils.showError(title: "Error Occurred", message: "Failed to generate encryption keys.")
            self.hideLoading()
            return
        }
        // newUser'properties has updated in Params.forSignUp
        
        // APICompletion block is run right after get response from server
        let completedBlock = {[unowned self] (_ succeeded: Bool, _ data:[String:Any]?) -> Void in
            if succeeded {
                self.doAfterSignUpSuccessfully(newUser, params, data)
            } else {
                self.hideLoading()
            }
        }
        
        // Send request to server. When completed, run completedBlock
        APIHandler.sharedInstance.makeCustomRequest(APIs.signUp, method: .post, parameters: params, completion: completedBlock)
    }
    
    func checkIfUserExists(username:String) -> Bool {
        
        return false
    }
    
    private func doAfterSignUpSuccessfully(_ newUser:User, _ params:[String:Any]?, _ data:[String:Any]?) {
        // Calculate K (session key)
        let B = Data(bytes: data![Keys.B] as! [UInt8])
        let _ = Global.shared.srpClient.calculateSessionKey(serverPublicKey: B)
        let ssk = Global.shared.srpClient.sessionKey?.bytes
        newUser.sessionKey = AppEncryptor.getSessionKey(bytes:ssk!)
        Global.shared.srpClient = nil // don't need it any more
        DDLog("KKK: \(newUser.sessionKey)")
        Global.shared.currentUser = newUser
        
        // Encrypt session key for storing in local device
        let currentUser = Global.shared.currentUser
        let enc_ssk = AppEncryptor.encryptAES256(plainData: (newUser.sessionKey)!, key: (currentUser?.aesMasterKey)!)
        
        var credentials = [String:Any]()
        credentials[Keys.i] = currentUser?.username
        credentials[Keys.enc_ak] = params![Keys.enc_ak]
        credentials[Keys.enc_ssk] = enc_ssk
        
        //                credentials[Keys.pubKey] = params[Keys.pubKey]
        //                credentials[Keys.enc_pk] = params[Keys.enc_pk]
        
        // Save credentials to disk
        Utils.saveToDisk(credentials:credentials)
        
        // Save hash of Private Key into Keychain
        Utils.saveInKeychain(secretKey: Global.shared.currentUser!.secretKey, user:Global.shared.currentUser)
        
        let info = [Keys.customServerURL: Global.shared.customURL!,
                    Keys.customServerAPIKey: Global.shared.customApiKey!]
        
        Utils.saveCustomServer(info: info)
        
        // Save Sync Method
        Utils.saveSyncMethod(SyncMethod.custom)
        Utils.renameDatabase()
        
        UIApplication.shared.endIgnoringInteractionEvents()
        self.showBackup(privateKey:newUser.secretKey)
    }
    
    @objc private func showBackup(privateKey:String) {
        var vc:ExportPrivateKey!
        if Utils.isPad() {
            vc = ExportPrivateKey(nibName: "ExportPrivateKeyPAD", bundle: nil)
        } else {
            vc = ExportPrivateKey(nibName: "ExportPrivateKey", bundle: nil)
        }
        vc.privateKey = privateKey
        vc.hidesBottomBarWhenPushed = true
        if Utils.isPad() {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = vc
            appDelegate.window?.makeKeyAndVisible()
        } else {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func ibaShowMoreInfo() {
        let vc = MoreInfoVC(nibName: "MoreInfoVC", bundle: nil)
        vc.question = "Sync with Custom Server"
        vc.info = """
        Our server is open source. So you can pull the source code to setup your own server then point the URL to it.
        
        + Custom Server URL must be HTTPS for secure connection.
        
        + API Key must be at least 10 characters.
        
        + Username must be at least 4 characters.
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
        frame.size.width = 450
        frame.origin.x = (screenSize.width - frame.size.width)/2.0
        frame.origin.y += 100
        self.vForm.frame = frame
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
        let username = self.tfUsername.text ?? ""
       
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
        
        guard !username.isEmpty else {
            self.lbError.text = "Please input username."
            self.lbError.isHidden = false
            return false
        }
        
        guard username.count >= 4 else {
            self.lbError.text = "Username must be at least 4 characters."
            self.lbError.isHidden = false
            return false
        }
        
        guard username.count <= 64 else {
            self.lbError.text = "Username must be in range of 10 to 64 characters."
            self.lbError.isHidden = false
            return false
        }
        
        guard !username.hasWhiteSpace() else {
            self.lbError.text = "Username must not contain whitespace."
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
