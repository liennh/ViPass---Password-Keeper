//
//  LocalSettingsVC.swift
//  ViPass
//
//  Created by Ngo Lien on 4/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class SettingsVC: BaseVC, UITextFieldDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var vStatusBar:UIView!
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var lbMinutes:UILabel!
    @IBOutlet weak var sliderLockApp:UISlider!
    @IBOutlet weak var lbAccountType:UILabel!
    @IBOutlet weak var lbExpiredAt:UILabel!
    @IBOutlet weak var btnGoPremium:UIButton!
    @IBOutlet weak var view0:UIView!
    @IBOutlet weak var view1:UIView!
    @IBOutlet weak var view2:UIView!
    @IBOutlet weak var view3:UIView!
    
    @IBOutlet weak var btn2:UIButton!
    @IBOutlet weak var btn3:UIButton!
    @IBOutlet weak var btn4:UIButton!
    @IBOutlet weak var btn5:UIButton!
    
    var textColorGoPremium:UIColor!
    
    var vFeelings:FeelingsView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default //.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenSize = UIScreen.main.bounds.size
        self.scrollView.contentSize = CGSize(width: screenSize.width, height: 761)
        
        self.adjustGUI()
        self.loadSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Check Account Status - Inapp Purchase
        self.loadAccountStatus()
        self.resetButtons()
    }
    
    func resetButtonBackground(_ sender:UIButton!) {
        // Higlight background color
        sender.backgroundColor = UIColor(hexString: "F4F4F4")
        let textColor = AppColor.COLOR_TABBAR_ACTIVE
        sender.titleLabel?.textColor = textColor
        sender.setTitleColor(textColor, for: .normal)
        sender.setTitleColor(textColor, for: .selected)
        sender.setTitleColor(textColor, for: .highlighted)
    }
    
    func resetButtons() {
        self.resetButtonBackground(self.btnGoPremium)
        self.resetButtonBackground(self.btn2)
        self.resetButtonBackground(self.btn3)
        self.resetButtonBackground(self.btn4)
        self.resetButtonBackground(self.btn5)
        
        if self.textColorGoPremium != nil {
            self.btnGoPremium.setTitleColor(self.textColorGoPremium, for: .normal)
        }
    }
    
    func loadAccountStatus() {
        let accountType = InappPurchase.getAccountType()
        let expiryDate = InappPurchase.getLocalExpiredAt()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let expiredAtString = dateFormatter.string(from: expiryDate)
        let now = Date()
        
        if accountType == AccountType.free_trial.rawValue {
            if expiryDate <= now {
                self.lbAccountType.text = "30-Days Free Trial"
                self.lbExpiredAt.text = "Has expired!"
            } else {
                self.lbAccountType.text = "30-Days Free Trial"
                self.lbExpiredAt.text = "Expires on \(expiredAtString)."
            }
            self.btnGoPremium.setTitle("Go Premium", for: .normal)
            self.btnGoPremium.isEnabled = true
            self.btnGoPremium.setTitleColor(AppColor.COLOR_TABBAR_ACTIVE, for: .normal)
        } else if accountType == AccountType.premium.rawValue {
            if expiryDate <= now {
                self.lbAccountType.text = "ViPass Premium"
                self.lbExpiredAt.text = "Has expired!"
                self.btnGoPremium.setTitle("Go Premium", for: .normal)
                self.btnGoPremium.isEnabled = true
                self.btnGoPremium.setTitleColor(AppColor.COLOR_TABBAR_ACTIVE, for: .normal)
            } else {
                self.lbAccountType.text = "ViPass Premium"
                self.lbExpiredAt.text = "Expires on \(expiredAtString)."
                self.btnGoPremium.setTitle("Enjoy Premium!", for: .normal)
                self.btnGoPremium.isEnabled = false
                self.btnGoPremium.setTitleColor(UIColor.gray, for: .normal)
            }
        }
        
        self.textColorGoPremium = self.btnGoPremium.titleColor(for: .normal)
    }
    
    func loadSettings() {
        self.sliderLockApp.value = Utils.getSettingsAutoLockApp()
        self.lbMinutes.text = "\(Int(self.sliderLockApp.value)) min"
    }
    
    @IBAction func ibaGoPremium() {
        var premiumVC:PremiumVC!
        if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            // iPhone 5S
            premiumVC = PremiumVC(nibName: "Premium5S", bundle: nil)
        } else if Utils.isPad() {
            // iPad
            premiumVC = PremiumVC(nibName: "PremiumPAD", bundle: nil)
        } else {
            premiumVC = PremiumVC(nibName: "PremiumVC", bundle: nil)
        }
        premiumVC.hidesBottomBarWhenPushed = true
        premiumVC.fromSettings = true
        self.navigationController?.pushViewController(premiumVC, animated: true)
    }
    
    @IBAction func ibaAutoLockChanged(sender:UISlider!) {
        self.lbMinutes.text = "\(Int(sender.value)) min"
        Utils.saveSettingsAutoLockApp(after: sender.value)
    }
    
    @IBAction func ibaChangeMasterPassword(sender:UIButton!) {
        // Higlight background color
        self.grayButtonTouchUp(sender)
        var vc:ChangePasswordVC!
        if Utils.isPad() {
            vc = ChangePasswordVC(nibName: "ChangePasswordPAD", bundle: nil)
        } else {
            vc = ChangePasswordVC(nibName: "ChangePasswordVC", bundle: nil)
        }
        
        if Utils.isPad() {
            let nav = UINavigationController(rootViewController: vc)
            nav.isNavigationBarHidden = true
            nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.present(nav, animated: true, completion: nil)
        } else {
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func ibaExportPrivateKey(sender:UIButton!) {
        // Higlight background color
        self.grayButtonTouchUp(sender)
        var vc:ExportPrivateKey!
        if Utils.isPad() {
            vc = ExportPrivateKey(nibName: "ExportPrivateKeyPAD", bundle: nil)
        } else {
            vc = ExportPrivateKey(nibName: "ExportPrivateKey", bundle: nil)
        }
        
        vc.privateKey = Utils.getSecretKey()
        vc.fromSetting = true
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        
        
        /* // Test BitCoin
        let password = Utils.generateWalletPassword(length: 32)
        let priv = Utils.generateWalletPrivateKey()
        
        
        let currentUser = Global.shared.currentUser
        // [UInt8]?
        guard let enc_password = AppEncryptor.encryptAES256(plainData: password.bytes, key: (currentUser?.sessionKey)!) else {
            return
        }
        guard let enc_priv = AppEncryptor.encryptAES256(plainData: priv.bytes, key: (currentUser?.sessionKey)!) else {
            return
        }
        
        let params = ["enc_password": enc_password,
                      "enc_priv": enc_priv,
                      "i": Global.shared.currentUser?.username] as [String : Any]
        
         APIHandler.sharedInstance.makeRequest("createNewWallet", method: .post, parameters: params, completion: { [unowned self] (_ succeeded: Bool, _ data: [String: Any]?) -> Void in
            if succeeded {
                // Re-encrypt Secret Key
                let xx = 10
            } else {
                self.hideLoading()
            }
        })
 */
    }
    
    @IBAction func ibaVisitWebsite(sender:UIButton!) {
        // Higlight background color
        self.grayButtonTouchUp(sender)
        let vc = InappWebView(nibName: "InappWebView", bundle: nil)
        vc.title = "1pass.vn"
        let url = URL(string: AppConfig.URL_Website)
        vc.url = url
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func ibaShareUsYourFeelings(sender:UIButton!) {
        // Higlight background color
        self.grayButtonTouchUp(sender)
        self.vFeelings = FeelingsView.getFromNib()
        self.vFeelings.settingVC = self
        self.vFeelings.show()
    }
    
    // MARK: Private methods
    private func adjustGUI() {
        //self.scrollView.isScrollEnabled = false
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            // self.adjustOnPhone6()
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            // self.adjustOnPhone6Plus()
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.adjustOnPhone5S()
        } else if UIDevice.current.screenType == .iPhoneX {
            self.adjustOnPhoneX()
        } else if Utils.isPad() {
            self.adjustOnPad()
        }
    }
    
    private func adjustOnPad() {
        let contentWidth:CGFloat = 450.0
        let screenSize = UIScreen.main.bounds.size
        var frame = self.view0.frame
        frame.size.width = contentWidth
        frame.origin.x = (screenSize.width - contentWidth)/2.0
        frame.origin.y += 100
        self.view0.frame = frame
        
        frame = self.view1.frame
        frame.size.width = contentWidth
        frame.origin.x = (screenSize.width - contentWidth)/2.0
        frame.origin.y += 100
        self.view1.frame = frame
        
        frame = self.view2.frame
        frame.size.width = contentWidth
        frame.origin.x = (screenSize.width - contentWidth)/2.0
        frame.origin.y += 100
        self.view2.frame = frame
        
        frame = self.view3.frame
        frame.size.width = contentWidth
        frame.origin.x = (screenSize.width - contentWidth)/2.0
        frame.origin.y += 100
        self.view3.frame = frame
    }
    
    private func adjustOnPhoneX() {
        self.vStatusBar.increaseHeight(value: 24)
    }
    
    private func adjustOnPhone5S() {
        self.lbTitle.font = UIFont.boldSystemFont(ofSize: 27)
        self.scrollView.isScrollEnabled = true
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.resetButtons()
    }
}
