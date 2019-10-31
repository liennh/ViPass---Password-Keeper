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

class ChangePasswordVC: BaseVC, UITextFieldDelegate {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tfCurrentPassword: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    @IBOutlet weak var lbError: UILabel!
    @IBOutlet weak var vForm: UIView!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var vStatusBar: UIView!
    @IBOutlet weak var vLoading: UIActivityIndicatorView!

    var keyboardHeight: CGFloat = 0.0

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
    @IBAction func ibaConfirm(sender: UIButton!) {
        self.view.endEditing(true)
        self.defaultButtonTouchUp(sender)
        guard self.validateInputForm() else {
            return
        }
        
        self.showLoading()
        if (Utils.currentSyncMethod() == SyncMethod.vipass) ||
           (Utils.currentSyncMethod() == SyncMethod.custom) {
            self.perform(#selector(doChangeServerPassword), with: nil, afterDelay: 0.5)
        } else {
            self.perform(#selector(doChangeLocalPassword), with: nil, afterDelay: 0.5)
        }
    }

    override func showLoading() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.vLoading.startAnimating()
        self.btnConfirm.superview?.bringSubview(toFront: self.vLoading)
        self.btnConfirm.setTitle("Changing...", for: .normal)
    }

    override func hideLoading() {
        self.vLoading.stopAnimating()
        self.btnConfirm.superview?.bringSubview(toFront: self.btnConfirm)
        self.btnConfirm.setTitle("Confirm", for: .normal)
        UIApplication.shared.endIgnoringInteractionEvents()
    }

    @objc private func doChangeServerPassword() {
        let currentUser = Global.shared.currentUser
        let username = (currentUser?.username)!
        let accountKey = (currentUser?.accountKey)!
//        let privateKey = (currentUser?.privateKey)!
        guard currentUser != nil else {
            return
        }
        let newPassword = self.tfPassword.text!
        // Generate aesMasterKey from New Master Password + Secret Key
        let aesMasterKey = AppEncryptor.getMasterKey(password: newPassword, secretKey: (currentUser?.secretKey)!)

        guard aesMasterKey != nil else {
            return
        }

        Global.shared.srpClient = Client(username: username, password: newPassword)
        let _ = Global.shared.srpClient.startAuthentication() // A:Data
        let s = Data(bytes: try! Random.generate(byteCount: 256)) // Salt
        let x = calculate_x(algorithm: .sha1, salt: s, username: username, password: newPassword)
        let v = calculate_v(group: .N1024, x: x) // Verifier

        let encSalt = AppEncryptor.encryptAES256(plainData: s.bytes, key: (currentUser?.sessionKey)!)
        let encVerifier = AppEncryptor.encryptAES256(plainData: v.serialize().bytes, key: (currentUser?.sessionKey)!)

        // Encrypt User Account Key and User Private Key using aesMasterKey
        let encAccountKey = AppEncryptor.encryptAES256(plainData: accountKey, key: aesMasterKey!)
        
//        let encPrivateKey = AppEncryptor.encryptAES256(plainData: privateKey, key: aesMasterKey!)

        let params = [Keys.i:username,
            Keys.enc_s: encSalt,
            Keys.enc_v: encVerifier,
            //Keys.enc_pk: encPrivateKey,
            Keys.enc_ak: encAccountKey] as [String : Any] 

        // Send request to server
        APIHandler.sharedInstance.makeRequest(APIs.changeUserPassword, method: .post, parameters: params, completion: { [unowned self] (_ succeeded: Bool, _ data: [String: Any]?) -> Void in
            if succeeded {
                // Re-encrypt Secret Key
                currentUser?.masterPassword = newPassword
                currentUser?.aesMasterKey = aesMasterKey!
                Utils.saveInKeychain(secretKey: (currentUser?.secretKey)!, user: currentUser)
                
                // Remove existing local Credentials
                Utils.removeCredentialsFromDisk()
                
                self.hideLoading()
                UIApplication.shared.beginIgnoringInteractionEvents()
                GoogleWearAlert.showAlert(title: "Changed!", .success)
                self.perform(#selector(self.forceUserToLoginAgain), with: nil, afterDelay: 2)
            } else {
                self.hideLoading()
            }
        })
    }// method
    
    @objc func forceUserToLoginAgain() {
        UIApplication.shared.endIgnoringInteractionEvents()
        (UIApplication.shared.delegate as! AppDelegate).showLoginOnly()
    }

    @objc private func doChangeLocalPassword() {
        let currentUser = Global.shared.currentUser
        guard currentUser != nil else {
            return
        }
        let newPassword = self.tfPassword.text!
        // Generate aesMasterKey from New Master Password + Secret Key
        let aesMasterKey = AppEncryptor.getMasterKey(password: newPassword, secretKey: (currentUser?.secretKey)!)

        guard aesMasterKey != nil else {
            return
        }

        currentUser?.masterPassword = newPassword
        currentUser?.aesMasterKey = aesMasterKey!

        let encAccountKey = AppEncryptor.encryptAES256(plainData: (currentUser?.accountKey)!, key: (currentUser?.aesMasterKey)!)

        let df = UserDefaults.standard
        var credentials = df.object(forKey: Keys.credentials) as! [String: Any]
        credentials[Keys.enc_ak] = encAccountKey
        // Save credentials to disk
        Utils.saveToDisk(credentials: credentials)
        // Save hash of Private Key into Keychain
        Utils.saveInKeychain(secretKey: Global.shared.currentUser!.secretKey, user: Global.shared.currentUser)
        self.hideLoading()
        self.ibaCancel()
        GoogleWearAlert.showAlert(title: "Changed!", .success)
    }

    @IBAction func ibaCancel() {
        self.view.endEditing(true)
        if Utils.isPad() {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }

    @IBAction func ibaSignIn(sender: UIButton!) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: Keyboard
    @objc func keyboardWillShow(noti: NSNotification) {
        if Utils.isPad() {
            return
        }
        
        let userInfo: NSDictionary = noti.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
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
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else if UIDevice.current.screenType == .iPhoneX {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: -30), animated: true)
        } else {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }

    // MARK: Private methods
    private func adjustGUI() {
        self.btnConfirm.layer.cornerRadius = Constant.Button_Corner_Radius
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
        self.scrollView.isScrollEnabled = false
        let screenSize = UIScreen.main.bounds.size
        var frame = self.vForm.frame
        frame.size.width = 450
        frame.origin.x = (screenSize.width - frame.size.width)/2.0
        frame.origin.y += 100
        self.vForm.frame = frame
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
    }

    private func validateInputForm() -> Bool {
        let currentUser = Global.shared.currentUser
        let currentPassword = self.tfCurrentPassword.text ?? ""
        let password = self.tfPassword.text ?? ""
        let confirmPassword = self.tfConfirmPassword.text ?? ""

        guard !currentPassword.isEmpty else {
            self.lbError.text = "Please input current master password."
            self.lbError.isHidden = false
            return false
        }

        guard currentPassword == currentUser?.masterPassword else {
            self.lbError.text = "Invalid current master password."
            self.lbError.isHidden = false
            return false
        }

        guard !password.isEmpty else {
            self.lbError.text = "Please input new master password."
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
            self.lbError.text = "Please confirm New Master Password."
            self.lbError.isHidden = false
            return false
        }

        guard password == confirmPassword else {
            self.lbError.text = "New Master Password does not match."
            self.lbError.isHidden = false
            return false
        }

        return true
    }

    // MARK: UITextField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }

    @IBAction func textFieldDidChange(_ textField: UITextField) {
        self.lbError.isHidden = true
        self.lbError.text = ""
    }

    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.ibaConfirm(sender: self.btnConfirm)
        return true
    }

}
