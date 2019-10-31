//
//  SignupVC.swift
//  ViPass
//
//  Created by Ngo Lien on 4/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit
import CryptoSwift

class SignupVC: BaseVC, UITextFieldDelegate {
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var tfUsername:HoshiTextField!
    @IBOutlet weak var tfPassword:HoshiTextField!
    @IBOutlet weak var tfConfirmPassword:HoshiTextField!
    @IBOutlet weak var lbError:UILabel!
    @IBOutlet weak var vForm:UIView!
    @IBOutlet weak var iconQuestion:UIImageView!
    @IBOutlet weak var vQuestion:UIView!
    @IBOutlet weak var btnSignUp:UIButton!
    @IBOutlet weak var vStatusBar:UIView!
    @IBOutlet weak var vLoading:UIActivityIndicatorView!
    var srpClient:Client!
    var mode:SyncMethod = SyncMethod.vipass // default is sync with ViPass Cloud
    
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
    
    // MARK: IBAction
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
        let newUser = User()
        newUser.username = Utils.getString(self.tfUsername.text!)
        newUser.masterPassword = Utils.getString(self.tfPassword.text!)
        newUser.secretKey = UUID().uuidString
        
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
        if self.mode == SyncMethod.custom {
            APIHandler.sharedInstance.makeCustomRequest(APIs.signUp, method: .post, parameters: params, completion: completedBlock)
        } else {
            APIHandler.sharedInstance.makeRequest(APIs.signUp, method: .post, parameters: params, completion: completedBlock)
        }
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
        
        if self.mode == SyncMethod.custom {
            let info = [Keys.customServerURL: Global.shared.customURL!,
                        Keys.customServerAPIKey: Global.shared.customApiKey!]
            
            Utils.saveCustomServer(info: info)
        }
        
        // Update Expired date
        // Init Free Trial period
        let today = Date()
        let freeTrialPeriod = AppConfig.freeTrialPeriod // days
        let expiryDate = Calendar.current.date(byAdding: .day, value: freeTrialPeriod, to: today)
        InappPurchase.updateLocal(expiredAt: expiryDate!)
        InappPurchase.setAccountType(0) // 0 is Free Trial
    
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
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func ibaCancel() {
        self.view.endEditing(true)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func ibaSignIn(sender:UIButton!) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ibaLearnMore(sender:UIButton!) {
        let vc = MoreInfoVC(nibName: "MoreInfoVC", bundle: nil)
        vc.question = "SIGN UP"
        vc.info = """
        ViPass is an end-to-end (E2E) encryption system. It means all encryption and decryption tasks happens in client side. We never send your master password to server or store else where. However, Our service needs to know that you are who you say you are. So you need to register with us an username.
        
        
        What about your master password?
        
        ViPass client app will use a special algorithsm to calculate out some core values for doing authentication in the future. They are:
        
        + SALT: A random value. Sent to server. Used to login later.
        
        + VERIFIER: Calculated from Salt, Username, Master Password and other values. Sent to server. Used to login later. An important note is that nobody can decode Master Password from Verifier.
        
        + PRIVATE KEY: NEVER sent to server. This works with your master password to encrypt/decrypt your data.
        
        + ACCOUNT KEY: Encrypted by Master Password and Private Key before sending to server. Used to protect your account data.
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
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 90), animated: true)
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else if UIDevice.current.screenType == .iPhoneX {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: -30), animated: true)
        } else if Utils.isPad() {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 15), animated: true)
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
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else if UIDevice.current.screenType == .iPhoneX {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: -30), animated: true)
        } else if Utils.isPad() {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    // MARK: Private methods
    private func adjustGUI() {
        self.iconQuestion.image = self.iconQuestion.image?.tint(UIColor.black)
        self.btnSignUp.layer.cornerRadius = Constant.Button_Corner_Radius
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
             self.adjustOnPhone6()
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            self.adjustOnPhone6Plus()
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.adjustOnPhone5S()
        } else if UIDevice.current.screenType == .iPhoneX {
            self.adjustOnPhoneX()
        } else if Utils.isPad() {
            self.adjustOnPad()
        }
    }
    
    private func adjustOnPad() {
        
    }
    
    private func adjustOnPhoneX() {
        self.vStatusBar.increaseHeight(value: 24)
        self.scrollView.isScrollEnabled = false
        //self.lbTitle.moveDown(distance: 5)
    }
    
    private func adjustOnPhone6() {
        self.scrollView.isScrollEnabled = false
    }
    
    private func adjustOnPhone6Plus() {
        //self.btnLogin.moveLeft(distance: 44)
        self.scrollView.isScrollEnabled = false
    }
    
    private func adjustOnPhone5S() {
        self.lbTitle.font = UIFont.boldSystemFont(ofSize: 27)
        self.vForm.moveUp(distance: 20)
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: self.scrollView.frame.size.height - 30)
    }
    
    private func validateInputForm() -> Bool {
        let username = self.tfUsername.text ?? ""
        let password = self.tfPassword.text ?? ""
        let confirmPassword = self.tfConfirmPassword.text ?? ""
        
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
        
        guard !password.isEmpty else {
            self.lbError.text = "Please input master password."
            self.lbError.isHidden = false
            return false
        }
        
        guard password.count >= 10 else {
            self.lbError.text = "Master password must be at least 10 characters."
            self.lbError.isHidden = false
            return false
        }
        
        guard password.count <= 64 else {
            self.lbError.text = "Master password must be in range of 10 to 64 characters."
            self.lbError.isHidden = false
            return false
        }
        
        guard !password.hasWhiteSpace() else {
            self.lbError.text = "Master password must not contain whitespace."
            self.lbError.isHidden = false
            return false
        }
        
        /*guard password.matches(for: AppConfig.password_rules) else {
            self.lbError.text = "Password must contain [A-Z], [a-z], [0-9], special characters."
            self.lbError.isHidden = false
            return false
        }*/
        
        guard !confirmPassword.isEmpty else {
            self.lbError.text = "Please confirm master password."
            self.lbError.isHidden = false
            return false
        }
        
        guard password == confirmPassword else {
            self.lbError.text = "Master password does not match."
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
