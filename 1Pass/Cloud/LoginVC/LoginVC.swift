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

class LoginVC: BaseVC, UITextFieldDelegate {
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var tfUsername:UITextField!
    @IBOutlet weak var tfPassword:UITextField!
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var lbError:UILabel!
    @IBOutlet weak var vForm:UIView!
    @IBOutlet weak var vRules:UIView!
    @IBOutlet weak var iconQuestion:UIImageView!
    @IBOutlet weak var vQuestion:UIView!
    @IBOutlet weak var btnLogin:UIButton!
    @IBOutlet weak var vStatusBar:UIView!
    @IBOutlet weak var vSignUp:UIView!
    @IBOutlet weak var vLoading:UIActivityIndicatorView!
    
    var mode:SyncMethod = SyncMethod.vipass // default is sync with ViPass Cloud
    
    var keyboardHeight:CGFloat = 0.0
    var loginOnly:Bool = false
    
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
        self.btnLogin.superview?.bringSubview(toFront: self.vLoading)
        self.btnLogin.setTitle("Logging In...", for: .normal)
    }
    
    override func hideLoading() {
        self.vLoading.stopAnimating()
        self.btnLogin.superview?.bringSubview(toFront: self.btnLogin)
        self.btnLogin.setTitle("Login", for: .normal)
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    @IBAction func ibaCancel(button:UIButton!) {
        self.view.endEditing(true)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func ibaSignUp(button:UIButton!) {
        self.view.endEditing(true)
        var vc:SignupVC?
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            vc = SignupVC(nibName: "SignupVC", bundle: nil)
        case .pad:
            vc = SignupVC(nibName: "SignupPAD", bundle: nil)
        default: break;
        }
        vc!.mode = self.mode
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // MARK: IBAction - Login
    @IBAction func ibaLogin(sender:UIButton!) {
        self.view.endEditing(true)
        self.defaultButtonTouchUp(sender)
        
        guard self.validateInputForm() else {
            return
        }
        self.tfUsername.text = self.tfUsername.text?.lowercased()
        self.showLoading()
        self.perform(#selector(loginFirstStep), with: nil, afterDelay: 0.5)
    }
    
    @objc private func loginFirstStep() {
        let newUser = User()
        newUser.username = Utils.getString(self.tfUsername.text!)
        newUser.masterPassword = Utils.getString(self.tfPassword.text!)
        Global.shared.currentUser = newUser
        
        let params = Params.forLoginFirstStep(user: newUser)
        
        // APICompletion block is run right after get response from server
        let completedBlock = {[unowned self] (_ succeeded: Bool, _ data:[String:Any]?) -> Void in
            if succeeded {
                self.loginLastStep(data)
            } else {
                self.hideLoading()
            }
        }
        
        // Send request to server. When completed, run completedBlock
        if self.mode == SyncMethod.custom {
            APIHandler.sharedInstance.makeCustomRequest(APIs.loginFirstStep, method: .post, parameters: params, completion: completedBlock)
        } else {
            APIHandler.sharedInstance.makeRequest(APIs.loginFirstStep, method: .post, parameters: params, completion: completedBlock)
        }
    }
    
    private func loginLastStep(_ data:[String:Any]?) {
        let s = data![Keys.s] as! [UInt8]
        let B = data![Keys.B] as! [UInt8]
        let (ok, result) = Params.forLoginLastStep(s: Data(bytes: s), B: Data(bytes: B))
        guard ok else {
            Utils.showError(title: "Error Occurred", message: result as! String)
            self.hideLoading()
            return
        }
        
        let params = result as! [String: Any]
        
        // APICompletion block is run right after get response from server
        let completedBlock = {[unowned self] (_ succeeded: Bool, _ data:[String:Any]?) -> Void in
            if succeeded {
                guard self.verifySession(data!) else {
                    self.hideLoading()
                    return
                }
                self.setupSession(data!)
            } else {
                self.hideLoading()
            }
        }
        
        // Send request to server. When completed, run completedBlock
        if self.mode == SyncMethod.custom {
            APIHandler.sharedInstance.makeCustomRequest(APIs.loginLastStep, method: .post, parameters: params, completion: completedBlock)
        } else {
            APIHandler.sharedInstance.makeRequest(APIs.loginLastStep, method: .post, parameters: params, completion: completedBlock)
        }
    }
    
    /*
     let dict = [Keys.pubKey: pubKey,
                 Keys.enc_ak: enc_ak,
                 Keys.enc_pk: enc_pk,
                 Keys.HAMK: HAMK]
     */
    private func verifySession(_ data:[String:Any]) -> Bool {
        let credentials = data[Keys.credentials] as! [String:Any]
        let HAMK = credentials[Keys.HAMK] as! [UInt8]
        let (ok, msg) = Global.shared.srpClient.verifySession(keyProof: Data(bytes: HAMK))
        guard ok else {
            Utils.showError(title: "Error Occurred", message: msg)
            return false
        }
        return true
    }
    
    private func setupSession(_ data:[String:Any]) {
        if self.mode == SyncMethod.custom {
            let info = [Keys.customServerURL: Global.shared.customURL!,
                        Keys.customServerAPIKey: Global.shared.customApiKey!]
            
            Utils.saveCustomServer(info: info)
        }
        
        var credentials = data[Keys.credentials] as! [String:Any]
        
        // Get hash of private key from Keychain
        guard let secretKey = Utils.getSecretKey() else { // Data?
            self.showImportPrivateKey(credentials: credentials)
            UIApplication.shared.endIgnoringInteractionEvents()
            return
        }
        
//        let pubKey = credentials[Keys.pubKey] as! [UInt8]
//        let enc_pk = credentials[Keys.enc_pk] as! [UInt8]
        
        let enc_ak = credentials[Keys.enc_ak] as! [UInt8]
        
        let currentUser = Global.shared.currentUser
        currentUser?.secretKey = secretKey
        
        // Decrypt enc_ak + enc_pk
        let aesMasterKey = AppEncryptor.getMasterKey(password: (currentUser?.masterPassword)!, secretKey: (currentUser?.secretKey)!)
        
        guard aesMasterKey != nil else {
            self.lbError.text = "Cannot generate master key."
            self.lbError.isHidden = false
            self.hideLoading()
            return
        }
        
        currentUser?.aesMasterKey = aesMasterKey
        
        guard let ak = AppEncryptor.decryptAES256(cipheredBytes: enc_ak, key: aesMasterKey!) else {
            self.showImportPrivateKey(credentials: credentials)
            UIApplication.shared.endIgnoringInteractionEvents()
            return
        }
        
        currentUser?.accountKey = ak
        
//        guard let pk = AppEncryptor.decryptAES256(cipheredBytes: enc_pk, key: aesMasterKey!) else {
//            self.showImportPrivateKey(credentials: credentials)
//            UIApplication.shared.endIgnoringInteractionEvents()
//            return
//        }
//        currentUser?.privateKey = pk
//        currentUser?.publicKey = pubKey
        
    
        let ssk = Global.shared.srpClient.sessionKey?.bytes
        currentUser?.sessionKey = AppEncryptor.getSessionKey(bytes:ssk!)
        Global.shared.srpClient = nil // don't need it any more
        DDLog("KKK: \(String(describing: currentUser?.sessionKey))")
        
        // Encrypt session key for storing in local device
        let enc_ssk = AppEncryptor.encryptAES256(plainData: (currentUser?.sessionKey)!, key: aesMasterKey!)
        credentials[Keys.enc_ssk] = enc_ssk
        credentials[Keys.i] = currentUser?.username
        credentials.removeValue(forKey: Keys.HAMK)
        
        // Save credentials to disk
        Utils.saveToDisk(credentials: credentials)
        
        self.hideLoading()
        
        // Update Expired At for Inapp Purchase
        let accountType = credentials[Keys.accountType] as! Int
        let expiredAt = credentials[Keys.expiredAt] as! String
        let expiryDate = Utils.dateFrom(string: expiredAt)
        InappPurchase.updateLocal(expiredAt: expiryDate!)
        InappPurchase.setAccountType(accountType) // Free Trial or Premium
        
        do {
            DataStore.configureMigration()
            let _ = try Realm()
            
            // show main screen
            (UIApplication.shared.delegate as! AppDelegate).showCloudMainVC()
        } catch {
            self.lbError.text = "Cannot open local database."
            self.lbError.isHidden = false
        }
    }
    
    @objc func showImportPrivateKey(credentials:[String:Any]!) {
        let vc:ImportPrivateKeyVC!
        if Utils.isPad() {
            vc = ImportPrivateKeyVC(nibName: "ImportPrivateKeyPAD", bundle: nil)
        } else {
            vc = ImportPrivateKeyVC(nibName: "ImportPrivateKeyVC", bundle: nil)
        }
        vc.credentials = credentials
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func ibaLearnMore(sender:UIButton!) {
        let vc = MoreInfoVC(nibName: "MoreInfoVC", bundle: nil)
        vc.question = "SIGN IN"
        vc.info = """
        ViPass is an end-to-end (E2E) encryption system. It means all encryption and decryption tasks happens in client side. We never send your master password to server or store else where. However, Our service needs to know that you are who you say you are. So you need to register with us an username.
        
        We describe here the steps in login process so that you can understand the core logic of our app.
        
        0. The client asks for username and master password.
        
        1. The client generates a and A from Password. Client sends username and A to server.
        
        2. Server generates b and B. B is generated from b and v (verifier from Database).
        
        3. Client and the server both generate U from A and B.
        
        4. Client generates client secret and sends signature to server (M1).
        
        5. Server generates server Secret and generates its own M1. Then compare with client's M1.
        
        6. Server generates M2 and send to Client.
        
        7. Client generates its own M2 and compares. Now mutual auth is established (without sending password nor secret).
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
        self.btnLogin.layer.cornerRadius = Constant.Button_Corner_Radius
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
             self.adjustOnPhone6()
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
             self.adjustOnPhone6Plus()
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.adjustOnPhone5S()
        } else if UIDevice.current.screenType == .iPhoneX {
            self.adjustOnPhoneX()
        } else if Utils.isPad() {
           // self.adjustOnPad()
        }
    }
    
    private func adjustOnPad() {
        let screenSize = UIScreen.main.bounds
        var frame = self.vForm.frame
        frame.size.width = 450
        frame.origin.x = (screenSize.width - frame.size.width)/2.0
       // frame.origin.y += 100
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
        if self.loginOnly == false {
            self.vSignUp.moveDown(distance: 30)
        }
    }
    
    private func adjustOnPhoneX() {
        self.vStatusBar.increaseHeight(value: 24)
        self.scrollView.isScrollEnabled = false
        if self.loginOnly == false {
            self.vSignUp.moveDown(distance: 30)
        }
    }
    
    private func adjustOnPhone5S() {
        self.lbTitle.font = UIFont.boldSystemFont(ofSize: 27)
        self.vForm.moveUp(distance: 20)
        self.lbError.moveDown(distance: 10)
        
        if self.loginOnly == true {
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: self.scrollView.frame.size.height - 100)
        } else {
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: self.scrollView.frame.size.height - 70)
        }
    }
    
    private func validateInputForm() -> Bool {
        let username = self.tfUsername.text ?? ""
        let password = self.tfPassword.text ?? ""
       
        guard !username.isEmpty else {
            self.lbError.text = "Please input username."
            self.lbError.isHidden = false
            return false
        }
        
        guard !password.isEmpty else {
            self.lbError.text = "Please input password."
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
        self.view.endEditing(true)
        self.ibaLogin(sender: self.btnLogin)
        return true
    }
    
}
