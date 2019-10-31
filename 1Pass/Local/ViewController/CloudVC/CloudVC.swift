//
//  CloudVC.swift
//  ViPass
//
//  Created by Ngo Lien on 4/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import KeychainSwift

class CloudVC: BaseVC, UITextFieldDelegate {
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var btnInfo:UIButton!
    @IBOutlet weak var tfUsername:UITextField!
    @IBOutlet weak var lbError:UILabel!
    @IBOutlet weak var btnSignUp:UIButton!
    @IBOutlet weak var iconArrowDown:UIImageView!
    @IBOutlet weak var lbCloud:UILabel!
    @IBOutlet weak var lbSetup:UILabel!
    @IBOutlet weak var lbHowItWorks:UILabel!
    @IBOutlet weak var vGetStarted:UIView!
    @IBOutlet weak var vHowItWorks:UIView!
    @IBOutlet weak var vContent:UIView!
    @IBOutlet weak var vStatusBar:UIView!
    @IBOutlet weak var vLoading:UIActivityIndicatorView!
    var srpClient:Client!
    
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
        self.scrollView.contentSize = CGSize(width: screenSize.width, height: 826) // 1067
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.adjustGUI()
    }
    
    @IBAction func ibaSignUp(sender:UIButton!) {
        self.view.endEditing(true)
        self.defaultButtonTouchUp(sender)
        guard self.validateInputForm() else {
            return
        }
        self.tfUsername.text = self.tfUsername.text?.lowercased()
        self.showLoading()
        self.perform(#selector(doSignUp), with: nil, afterDelay: 0.5)
    }
    
    override func showLoading() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.vLoading.startAnimating()
        self.btnSignUp.superview?.bringSubview(toFront: self.vLoading)
        self.btnSignUp.setTitle("Signing Up...", for: .normal)
    }
    
    override func hideLoading() {
        self.vLoading.stopAnimating()
        self.btnSignUp.superview?.bringSubview(toFront: self.btnSignUp)
        self.btnSignUp.setTitle("SignUp", for: .normal)
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    @objc private func doSignUp() {
        let password = Global.shared.currentUser?.masterPassword
        let secretKey = Global.shared.currentUser?.secretKey
        let accountKey = Global.shared.currentUser?.accountKey
        
        let newUser = User()
        newUser.username = self.tfUsername.text!
        newUser.masterPassword = password
        newUser.secretKey = secretKey
        newUser.accountKey = accountKey
        
        guard let params = Params.forSignUp(user:newUser) else {
            Utils.showError(title: "Error Occurred", message: "Failed to generate encryption keys.")
            self.hideLoading()
            return
        }
        // newUser'properties has updated in Params.forSignUp
        
        // Send request to server
        APIHandler.sharedInstance.makeRequest(APIs.signUp, method: .post, parameters: params, completion: {[unowned self] (_ succeeded: Bool, _ data:[String:Any]?) -> Void in
            if succeeded {
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
                credentials[Keys.enc_ak] = params[Keys.enc_ak]
                credentials[Keys.enc_ssk] = enc_ssk
                
                //                credentials[Keys.pubKey] = params[Keys.pubKey]
                //                credentials[Keys.enc_pk] = params[Keys.enc_pk]
                
                // Save credentials to disk
                Utils.saveToDisk(credentials:credentials)
                
                // Save hash of Private Key into Keychain
                let keychain = KeychainSwift()
                keychain.clear() // remove secret key of username "local"
                Utils.saveInKeychain(secretKey: Global.shared.currentUser!.secretKey, user:Global.shared.currentUser)
                
                // Save Sync Method
                Utils.saveSyncMethod(SyncMethod.vipass)
                Utils.renameDatabase()
                
                // Update Expired date
                // Init Free Trial period
                let today = Date()
                let freeTrialPeriod = AppConfig.freeTrialPeriod // days
                let expiryDate = Calendar.current.date(byAdding: .day, value: freeTrialPeriod, to: today)
                InappPurchase.updateLocal(expiredAt: expiryDate!)
                InappPurchase.setAccountType(0) // 0 is Free Trial
                
                UIApplication.shared.endIgnoringInteractionEvents()
                self.showBackup(privateKey:newUser.secretKey)
            } else {
                self.hideLoading()
            }
        })
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
        
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.window?.rootViewController = vc
        appDelegate.window?.makeKeyAndVisible()
    }
    
    @IBAction func ibaLearnMore(sender:UIButton!) {
        let vc = InappWebView(nibName: "InappWebView", bundle: nil)
        vc.title = "White Paper"
        let url = URL(string: AppConfig.URL_White_Paper)
        vc.url = url
        self.navigationController?.present(vc, animated: true, completion: nil)
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
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 350), animated: true)
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 330), animated: true)
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 420), animated: true)
        } else if UIDevice.current.screenType == .iPhoneX {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 310), animated: true)
        } else if UIDevice.current.screenType == .iPhone4_4S {
            //self.adjustOnPhone4S()
        }
    }
    
    @objc func keyboardWillHide(noti: NSNotification) {
        let screenSize = UIScreen.main.bounds.size
        var frame = self.scrollView.frame
        frame.size.height = screenSize.height
        self.scrollView.frame = frame
    }
    
    // MARK: Private methods
    private func adjustGUI() {
        self.iconArrowDown.image = self.iconArrowDown.image?.tint(AppColor.COLOR_TABBAR_ACTIVE)
        self.btnSignUp.layer.cornerRadius = Constant.Button_Corner_Radius
        
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
             //self.adjustOnPhone6()
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
    }
    
    private func adjustOnPhone5S() {
        self.vContent.increaseHeight(value: 44)
        self.lbCloud.font = UIFont.boldSystemFont(ofSize: 27)
        self.lbSetup.font = UIFont.boldSystemFont(ofSize: 27)
        self.lbHowItWorks.font = UIFont.boldSystemFont(ofSize: 27)
        self.vGetStarted.moveDown(distance: 44)
        self.vHowItWorks.moveDown(distance: 44)
        let screenSize = UIScreen.main.bounds
        self.scrollView.contentSize = CGSize(width: screenSize.width, height: 870)
    }
    
    private func validateInputForm() -> Bool {
        let username = self.tfUsername.text ?? ""
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
            self.lbError.text = "Username must be in range of 4 to 64 characters."
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
        if( (textField == tfUsername) && (string == " ") ) {
            return false // Prevent whitespace from Username
        } else {
            return true
        }
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        self.lbError.isHidden = true
        self.lbError.text = ""
        if textField == tfUsername {
            textField.text = textField.text?.lowercased() // force username is lowercase
        }
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.ibaSignUp(sender: self.btnSignUp)
        return true
    }
    
}
