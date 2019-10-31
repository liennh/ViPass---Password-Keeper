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

class LocalSettingsVC: BaseVC, UITextFieldDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var vStatusBar:UIView!
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var lbMinutes:UILabel!
    @IBOutlet weak var lbSyncDesc:UILabel!
    @IBOutlet weak var tfCustomURL:UITextField!
    @IBOutlet weak var btnSyncCustomServer:UIButton!
    @IBOutlet weak var sliderLockApp:UISlider!
    
    @IBOutlet weak var view1:UIView!
    @IBOutlet weak var view2:UIView!
    @IBOutlet weak var view3:UIView!
    @IBOutlet weak var view4:UIView!
    
    @IBOutlet weak var btn1:UIButton!
    @IBOutlet weak var btn2:UIButton!
    @IBOutlet weak var btn3:UIButton!
    @IBOutlet weak var btn4:UIButton!
    
    
    var vFeelings:FeelingsView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default //.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenSize = UIScreen.main.bounds.size
        self.scrollView.contentSize = CGSize(width: screenSize.width, height: 786)
        
        self.adjustGUI()
        self.loadSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.resetButtons()
    }
    
    func loadSettings() {
        self.sliderLockApp.value = Utils.getSettingsAutoLockApp()
        self.lbMinutes.text = "\(Int(self.sliderLockApp.value)) min"
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
        self.resetButtonBackground(self.btn1)
        self.resetButtonBackground(self.btn2)
        self.resetButtonBackground(self.btn3)
        self.resetButtonBackground(self.btn4)
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.resetButtons()
    }
    
    @IBAction func ibaClearClipboard(sender:UIButton!) {
        // Higlight background color
        self.grayButtonTouchUp(sender)
        UIPasteboard.general.string = ""
    }
    
    @IBAction func ibaSyncWithCustomServer(sender:UIButton!) {
        // Higlight background color
        self.grayButtonTouchUp(sender)
        var vc:SyncCustomServer2!
        if Utils.isPad() {
            vc = SyncCustomServer2(nibName: "SyncCustomServer2PAD", bundle: nil)
        } else {
            vc = SyncCustomServer2(nibName: "SyncCustomServer2", bundle: nil)
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true
        if Utils.isPad() {
            nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
        }
        self.present(nav, animated: true, completion: nil)
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
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            // self.adjustOnPhone6()
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            // self.adjustOnPhone6Plus()
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.adjustOnPhone5S()
        } else if UIDevice.current.screenType == .iPhoneX {
            self.adjustOnPhoneX()
        } else if Utils.isPad() {
            //self.adjustOnPad()
        }
    }
    
    private func adjustOnPad() {
        let contentWidth:CGFloat = 450.0
        let screenSize = UIScreen.main.bounds.size
        var frame = self.view1.frame
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
        
        frame = self.view4.frame
        frame.size.width = contentWidth
        frame.origin.x = (screenSize.width - contentWidth)/2.0
        frame.origin.y += 100
        self.view4.frame = frame
    }
    
    private func adjustOnPhoneX() {
        self.vStatusBar.increaseHeight(value: 24)
    }
    
    private func adjustOnPhone5S() {
        self.lbTitle.font = UIFont.boldSystemFont(ofSize: 27)
        self.lbSyncDesc.font = UIFont.systemFont(ofSize: 16)
        
    }
    
    // MARK: UITextField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if( (textField == self.tfCustomURL) && (string == " ") ) {
            return false // Prevent whitespace from Username
        } else {
            return true
        }
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        /*self.lbError.isHidden = true
        self.lbError.text = ""
        if textField == tfUsername {
            textField.text = textField.text?.lowercased() // force username is lowercase
        }*/
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //self.ibaSignUp(sender: self.btnSignUp)
        return true
    }
    
}
