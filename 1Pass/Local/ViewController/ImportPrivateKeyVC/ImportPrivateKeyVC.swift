//
//  ImportPrivateKeyVC.swift
//  ViPass
//
//  Created by Ngo Lien on 6/1/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ImportPrivateKeyVC:BaseVC, UITextFieldDelegate {
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var tfPrivateKey:UITextField!
    @IBOutlet weak var btnInfo:UIButton!
    @IBOutlet weak var btnScan:UIButton!
    @IBOutlet weak var btnPaste:UIButton!
    @IBOutlet weak var btnContinue:UIButton!
    @IBOutlet weak var vForm:UIView!
    @IBOutlet weak var iconQuestion:UIImageView!
    @IBOutlet weak var vQuestion:UIView!
    @IBOutlet weak var vStatusBar:UIView!
    @IBOutlet weak var vTextField:UIView!
    @IBOutlet weak var lbError:UILabel!
    @IBOutlet weak var vLoading:UIActivityIndicatorView!
    
    var credentials:[String:Any]!
    var keyboardHeight:CGFloat = 0.0
    var isScanning = false
    
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
        self.scrollView.contentSize = CGSize(width: screenSize.width, height: 700)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.adjustGUI()
    }
    
    @IBAction func ibaScan(button:UIButton!) {
        self.isScanning = true
        self.view.endEditing(true)
        
        let qrVC = ScanViewController(scanKeyCompletion: { [unowned self] privateKey in
            self.tfPrivateKey.text = privateKey
            self.ibaContinue(sender: self.btnContinue)
        })
        self.present(qrVC, animated: true, completion: {})
    }
    
    @IBAction func ibaPaste(button:UIButton!) {
        self.isScanning = false
        self.tfPrivateKey.text = UIPasteboard.general.string ?? ""
        if (self.tfPrivateKey.text?.isEmpty)! == false {
            self.view.endEditing(true)
            self.ibaContinue(sender: self.btnContinue)
        }
    }
    
    @IBAction func ibaShowMoreInfo() {
        let vc = MoreInfoVC(nibName: "MoreInfoVC", bundle: nil)
        vc.question = "What is private key?"
        vc.info = """
        It seems this is the first time you login on this device. Please provide your Private Key. If you have another device running this app. You can find it in the [ Settings > Export Private Key ].
        
        In fact, your Private Key works with your Master Password – which only you know – to encrypt your data and keep it safe. It's even safer than using two factor authentication. In case of our server is hacked, your data is still safe.
        """
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func ibaContinue(sender:UIButton!) {
        self.view.endEditing(true)
        self.defaultButtonTouchUp(sender)
        guard self.validateInputForm() else {
            return
        }
        
        self.showLoading()
        
        self.perform(#selector(doUnlock), with: nil, afterDelay: 0.5)
    }
    
    @objc private func doUnlock() {
        //let pubKey = self.credentials[Keys.pubKey] as! [UInt8]
        //let enc_pk = self.credentials[Keys.enc_pk] as! [UInt8]
        
        let enc_ak = self.credentials[Keys.enc_ak] as! [UInt8]
        let currentUser = Global.shared.currentUser
        
        let secretKey = self.tfPrivateKey.text
        
        // Decrypt enc_ak + enc_pk
        let aesMasterKey = AppEncryptor.getMasterKey(password: (currentUser?.masterPassword)!, secretKey: secretKey!)
        
        guard aesMasterKey != nil else {
            self.hideLoading()
            let alert = AlertView.getFromNib(title: "Cannot generate master key.")
            alert.show()
            return
        }

        currentUser?.aesMasterKey = aesMasterKey
        
        guard let ak = AppEncryptor.decryptAES256(cipheredBytes: enc_ak, key: aesMasterKey!) else {
            self.showDecryptionError()
            self.hideLoading()
            return
        }
        
        currentUser?.accountKey = ak
        
//        guard let pk = AppEncryptor.decryptAES256(cipheredBytes: enc_pk, key: aesMasterKey!) else {
//            self.showDecryptionError()
//            self.hideLoading()
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
        self.credentials[Keys.enc_ssk] = enc_ssk
        self.credentials[Keys.i] = currentUser?.username
        self.credentials.removeValue(forKey: Keys.HAMK)
        
        // Save credentials to disk
        Utils.saveToDisk(credentials: credentials)
        
        // Save hash of Private Key into Keychain
        Utils.saveInKeychain(secretKey: secretKey!, user: currentUser)

        UIApplication.shared.endIgnoringInteractionEvents()
        self.hideLoading()
        
        // Update Expired At for Inapp Purchase
        let accountType = self.credentials[Keys.accountType] as! Int
        let expiredAt = self.credentials[Keys.expiredAt] as! String
        let expiryDate = Utils.dateFrom(string: expiredAt)
        InappPurchase.updateLocal(expiredAt: expiryDate!)
        InappPurchase.setAccountType(accountType) // Free Trial or Premium
        
        do {
            DataStore.configureMigration()
            let _ = try Realm()
            // show main screen
            (UIApplication.shared.delegate as! AppDelegate).showCloudMainVC()
        } catch {
            let alert = AlertView.getFromNib(title: "Cannot init local database.")
            alert.show()
        }
    }
    
    private func showDecryptionError() {
        self.lbError.text = "Invalid Private Key."
        self.lbError.isHidden = false
        self.makeRed(textField: self.tfPrivateKey)
    }
   
    override func showLoading() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.vLoading.startAnimating()
        self.btnContinue.superview?.bringSubview(toFront: self.vLoading)
        self.btnContinue.setTitle("Processing...", for: .normal)
    }
    
    override func hideLoading() {
        self.vLoading.stopAnimating()
        self.btnContinue.superview?.bringSubview(toFront: self.btnContinue)
        self.btnContinue.setTitle("Continue", for: .normal)
        UIApplication.shared.endIgnoringInteractionEvents()
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
            // do nothing
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 15), animated: true)
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            //self.scrollView.setContentOffset(CGPoint(x: 0, y: 10), animated: true)
        } else if UIDevice.current.screenType == .iPhoneX {
            // self.scrollView.setContentOffset(CGPoint(x: 0, y: 1), animated: true)
        } else if Utils.isPad() {
           // self.scrollView.setContentOffset(CGPoint(x: 0, y: 20), animated: true)
        }
    }
    
    @objc func keyboardWillHide(noti: NSNotification) {
        let screenSize = UIScreen.main.bounds.size
        var frame = self.scrollView.frame
        frame.size.height = screenSize.height
        self.scrollView.frame = frame
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
           // self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            //self.scrollView.setContentOffset(CGPoint(x: 0, y: -15), animated: true)
        } else if UIDevice.current.screenType == .iPhoneX {
            // self.scrollView.setContentOffset(CGPoint(x: 0, y: -30), animated: true)
        } else if Utils.isPad() {
            //self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    // MARK: Private methods
    private func adjustGUI() {
        self.iconQuestion.image = self.iconQuestion.image?.tint(UIColor.black)
        self.vTextField.layer.cornerRadius = Constant.Button_Corner_Radius
        self.vTextField.layer.borderWidth = 1.0
        self.vTextField.layer.borderColor = AppColor.COLOR_TABBAR_ACTIVE.cgColor
        
        self.btnPaste.layer.cornerRadius = Constant.Button_Corner_Radius
        self.btnScan.layer.cornerRadius = Constant.Button_Corner_Radius
        self.btnContinue.layer.cornerRadius = Constant.Button_Corner_Radius
        
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            // self.adjustOnPhone6()
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            //self.adjustOnPhone6Plus()
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.adjustOnPhone5S()
        } else if UIDevice.current.screenType == .iPhoneX {
            //self.adjustOnPhoneX()
        } else if Utils.isPad() {
            self.adjustOnPad()
        }
    }
    
    private func adjustOnPad() {
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
        self.scrollView.isScrollEnabled = false
    }
    
    private func validateInputForm() -> Bool {
        let privateKey = self.tfPrivateKey.text ?? ""
        guard !privateKey.isEmpty else {
            self.makeRed(textField: self.tfPrivateKey)
            self.lbError.text = "Please input your private key."
            self.lbError.isHidden = false
            return false
        }
        return true
    }
    
    private func makeRed(textField:UITextField!) {
        self.vTextField.layer.borderColor = UIColor.red.cgColor
    }
    
    private func removeRed(textField:UITextField!) {
        self.vTextField.layer.borderColor = AppColor.COLOR_TABBAR_ACTIVE.cgColor
        self.lbError.isHidden = true
    }
    
    // MARK: UITextField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        textField.text = textField.text?.uppercased() // force content is uppercased
        self.removeRed(textField: self.tfPrivateKey)
        self.isScanning = false
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
