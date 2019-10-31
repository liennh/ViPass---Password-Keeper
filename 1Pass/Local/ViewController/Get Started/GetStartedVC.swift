//
//  GetStartedVC.swift
//  ViPass
//
//  Created by Ngo Lien on 4/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class GetStartedVC: BaseVC {
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var btnSyncViPass:UIButton!
    //@IBOutlet weak var btnSyncCustom:UIButton!
    @IBOutlet weak var btnUseOffline:UIButton!
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var vTerms:UIView!
    @IBOutlet weak var vButtons:UIView!
    @IBOutlet weak var logo:UIImageView!
    @IBOutlet weak var lbSync:UILabel!
    @IBOutlet weak var lbTerms:UILabel!
    @IBOutlet weak var lbAnd:UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default //.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnSyncViPass.layer.cornerRadius = Constant.Button_Corner_Radius
        self.btnSyncViPass.layer.cornerRadius = Constant.Button_Corner_Radius
        self.adjustGUI()
    }
    
    // MARK: IBACtion
    @IBAction func ibaSyncWithViPassCloud(sender:UIButton!) {
        self.defaultButtonTouchUp(sender)
        var vc:LoginVC?
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            vc = LoginVC(nibName: "LoginVC", bundle: nil)
        case .pad:
            vc = LoginVC(nibName: "LoginPAD", bundle: nil)
        default: break;
        }
        self.navigationController?.pushViewController(vc!, animated: true)
        // Save Sync Method
        Utils.saveSyncMethod(SyncMethod.vipass)
    }
    
    @IBAction func ibaSyncWithCustomServer(sender:UIButton!) {
        
        //////// Start tests
       /*
        let qrVC = ScanViewController(scanKeyCompletion: { privateKey in
            DDLog("MY XXXX privateKey is: \(privateKey)")
        })
        self.present(qrVC, animated: true, completion: {})
        
        return
        
        
        */
    
        
        //////////// end tests
        
       // self.blueButtonTouchUp(sender)
        var vc:SyncCustomServer!
        if Utils.isPad() {
            vc = SyncCustomServer(nibName: "SyncCustomServerPAD", bundle: nil)
        } else {
            vc = SyncCustomServer(nibName: "SyncCustomServer", bundle: nil)
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
        // Save Sync Method
        Utils.saveSyncMethod(SyncMethod.custom)
    }
    
    @IBAction func ibaUseOffline(sender:UIButton!) {
        //self.whiteButtonTouchUp(sender)
        var vc:SetupVC?
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            vc = SetupVC(nibName: "SetupVC", bundle: nil)
        case .pad:
            vc = SetupVC(nibName: "SetupPAD", bundle: nil)
        default: break;
        }
        self.navigationController?.pushViewController(vc!, animated: true)
        // Save Sync Method
        Utils.saveSyncMethod(SyncMethod.offline)
    }
    
    @IBAction func ibaShowTermsOfService(sender:UIButton!) {
        let vc = InappWebView(nibName: "InappWebView", bundle: nil)
        vc.title = "Terms of Service"
        let url = URL(string: AppConfig.URL_Terms_Of_Use)
        vc.url = url
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func ibaShowPrivacyPolicy(sender:UIButton!) {
        let vc = InappWebView(nibName: "InappWebView", bundle: nil)
        vc.title = "Privacy Policy"
        let url = URL(string: AppConfig.URL_Privacy_Policy)
        vc.url = url
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    // MARK: Private method
    private func adjustGUI() {
        self.btnSyncViPass.layer.cornerRadius =  Constant.Button_Corner_Radius
        //self.btnSyncCustom.layer.cornerRadius =  Constant.Button_Corner_Radius
       
        // Button Use Offline
        self.btnUseOffline.layer.cornerRadius =  Constant.Button_Corner_Radius
        
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            // self.adjustOnPhone6()
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            //self.adjustOnPhone6Plus()
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.adjustOnPhone5S()
        } else if UIDevice.current.screenType == .iPhoneX {
            self.adjustOnPhoneX()
        } else if Utils.isPad() {
            self.adjustOnPad()
        }
    }
    
    private func adjustOnPad() {
        if UIDevice.current.isPadPro129 {
            var frame = self.vButtons.frame
            frame.origin.y = 587
            self.vButtons.frame = frame
            
            frame = self.logo.frame
            frame.origin.y = 301
            self.logo.frame = frame
        } else if UIDevice.current.isPadPro105 {
            let xxx = 1
            // do nothing
        } else {
            // iPad 9.7, iPad mini
            let xxx = 1
            // do nothing
        }
    }
    
    private func adjustOnPhoneX() {
        //self.vStatusBar.increaseHeight(value: 24)
        self.lbTitle.moveDown(distance: 25)
        self.vButtons.moveDown(distance: 25)
        self.vTerms.moveUp(distance: 50)
        self.logo.moveDown(distance: 30)
    }
    
    private func adjustOnPhone6Plus() {
        self.lbTitle.font = UIFont.boldSystemFont(ofSize: 30)
        self.vButtons.moveUp(distance: 20)
    }
    private func adjustOnPhone5S() {
        self.lbTitle.font = UIFont.boldSystemFont(ofSize: 27)
        self.vButtons.moveUp(distance: 100)
        self.logo.isHidden = true
        self.lbSync.font = UIFont.systemFont(ofSize: 15)
        self.lbTerms.font = UIFont.systemFont(ofSize: 15)
        self.lbAnd.font = UIFont.systemFont(ofSize: 15)
    }
    
}
