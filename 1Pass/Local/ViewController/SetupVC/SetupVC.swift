//
//  SetupVC.swift
//  ViPass
//
//  Created by Ngo Lien on 4/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class SetupVC: BaseVC, UITextFieldDelegate {
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var tfPassword:UITextField!
    @IBOutlet weak var tfConfirmPassword:UITextField!
    @IBOutlet weak var btnSetUp:UIButton!
    @IBOutlet weak var btnCancel:UIButton!
    @IBOutlet weak var lbError:UILabel!
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var iconQuestion:UIImageView!
    @IBOutlet weak var vQuestion:UIView!
    @IBOutlet weak var vForm:UIView!
    @IBOutlet weak var vStatusBar:UIView!
    @IBOutlet weak var vLoading:UIActivityIndicatorView!
    
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
    
    // MARK: Setup App the first time
    @IBAction func ibaSetUp(sender:UIButton) {
        self.view.endEditing(true)
        self.defaultButtonTouchUp(sender)
        
        // Do logic Setup here
        guard self.validateInputForm() else {
            return
        }
        
        self.showLoading()
        self.perform(#selector(doSetUp), with: nil, afterDelay: 0.5)
    }
    
    @objc func doSetUp() {
        // Init default user
        let currentUser = User()
        currentUser.username = AppConfig.local_username
        currentUser.masterPassword = self.tfPassword.text ?? ""
        currentUser.secretKey = UUID().uuidString
        //currentUser.accountKey = GenUtils.generateAccountKey()
        guard let params = Params.forSetUp(user:currentUser) else {
            self.lbError.text = "Failed to generate encryption keys."
            self.lbError.isHidden = false
            self.hideLoading()
            return
        }
        // currentUser'properties has updated in Params.forSetUp
        
        Global.shared.currentUser = currentUser
        
        do {
            DataStore.configureMigration()
            let _ = try Realm()
            // Save credentials to disk
            Utils.saveToDisk(credentials:params)
            
            // Save hash of Private Key into Keychain
            Utils.saveInKeychain(secretKey: Global.shared.currentUser!.secretKey, user:Global.shared.currentUser)
            self.hideLoading()
            // show main screen
            (UIApplication.shared.delegate as! AppDelegate).showLocalMainVC()
           // Utils.saveSetupStatus() // don't need
        } catch {
            self.lbError.text = "Cannot init local database."
            self.lbError.isHidden = false
            self.hideLoading()
        }
    }
    
    @IBAction func ibaCancel(sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    private func validateInputForm() -> Bool {
        let password = self.tfPassword.text ?? ""
        let confirmPassword = self.tfConfirmPassword.text ?? ""
        
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
    
    @IBAction func ibaShowMoreInfo() {
        let vc = MoreInfoVC(nibName: "MoreInfoVC", bundle: nil)
        vc.question = "What is master password?"
        vc.info = """
        In fact, your master password – which only you know – is used to encrypt your data and keep it safe.
        
        Please remember it! If you forget it, there is no way to recover your data. However, you can change it later.
        
        We recommend to follow these guidlines to make a strong master password.
        + At least 10 characters.
        + At least an Uppercase.
        + At least a Number.
        + At least a special character.
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
        if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 60), animated: true)
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            // Do nothing
        } else if UIDevice.current.screenType == .iPhoneX {
            // Do nothing
        } else if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            // Do nothing
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
        if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            // Do nothing
        } else if UIDevice.current.screenType == .iPhoneX {
            // Do nothing
        } else if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            // Do nothing
        } else {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
        
    }
    
    override func showLoading() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.vLoading.startAnimating()
        self.btnSetUp.superview?.bringSubview(toFront: self.vLoading)
        self.btnSetUp.setTitle("Setting Up...", for: .normal)
    }
    
    override func hideLoading() {
        self.vLoading.stopAnimating()
        self.btnSetUp.superview?.bringSubview(toFront: self.btnSetUp)
        self.btnSetUp.setTitle("Go", for: .normal)
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    // MARK: Private methods
    private func adjustGUI() {
        self.iconQuestion.image = self.iconQuestion.image?.tint(UIColor.black)
        self.btnSetUp.layer.cornerRadius = Constant.Button_Corner_Radius
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
        self.lbTitle.moveUp(distance: 20)
        self.vForm.moveUp(distance: 20)
        self.vQuestion.moveUp(distance: 17)
        self.btnCancel.moveUp(distance: 20)
    }
    
    // MARK: UITextField
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        self.lbError.isHidden = true
        self.lbError.text = ""
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.ibaSetUp(sender: self.btnSetUp)
        return true
    }
    
}
