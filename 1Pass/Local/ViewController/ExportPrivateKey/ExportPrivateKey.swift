//
//  ExportPrivateKey.swift
//  ViPass
//
//  Created by Ngo Lien on 6/4/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ExportPrivateKey:BaseVC {
    @IBOutlet weak var vStatusBar:UIView!
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var vQRCode:UIImageView!
    @IBOutlet weak var lbPrivateKey:UILabel!
    @IBOutlet weak var btnDone:UIButton!
    @IBOutlet weak var btnCopy:UIButton!
    @IBOutlet weak var btnPrint:UIButton!
    @IBOutlet weak var vAction:UIView!
    @IBOutlet weak var vContent:UIView!
    
    
    var fromSetting:Bool = false
    var privateKey:String!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default //.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.adjustGUI()
        self.lbPrivateKey.text = self.privateKey
        self.vQRCode.image = self.privateKey.qrCode(outputSize: self.vQRCode.frame.size)
        
        // Show alert
        self.perform(#selector(showAlert), with: nil, afterDelay: 0.5)
    }
    
    @objc func showAlert() {
        let alert = AlertView.getFromNib(title: "The Private Key works with your Master Password to encrypt your data. If you lose it then there is no way to retrieve the data. So make sure to write it down and keep it secret.")
        alert.show()
        alert.setOKButton(title:"Got It")
    }
    
    @IBAction func ibaCopy(button:UIButton!) {
        // Copy to Clipboard
        UIPasteboard.general.string = self.privateKey
        //UIPasteboard.general.image = self.vContent.toImage()
        GoogleWearAlert.showAlert(title: "Copied", .success)
    }
    
    @IBAction func ibaPrint(button:UIButton!) {
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = "Backup Private Key"
        
        // Set up print controller
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        
        // Assign a UIImage version of my UIView as a printing iten
        printController.printingItem = self.vContent.toImage()
        
        // Do it
        printController.present(from: self.view.frame, in: self.view, animated: true, completionHandler: nil)
    }
    
    @IBAction func ibaContinue(button:UIButton!) {
        if self.fromSetting {
            self.navigationController?.popViewController(animated: true)
        } else {
            do {
                DataStore.configureMigration()
                let _ = try Realm()
                
                // show main screen
                (UIApplication.shared.delegate as! AppDelegate).showCloudMainVC()
            } catch {
                Utils.showError(title: "Cannot init local database.", message: "")
            }
        }
    }
    
    override var hidesBottomBarWhenPushed: Bool {
        get {
            return navigationController?.topViewController == self
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }
    
    // MARK: Private methods
    private func adjustGUI() {
        if self.fromSetting {
            self.lbTitle.text = "Export Private Key"
        }
        self.btnCopy.layer.cornerRadius = Constant.Button_Corner_Radius
        self.btnPrint.layer.cornerRadius = Constant.Button_Corner_Radius
        
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            // self.adjustOnPhone6()
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
        let screenSize = UIScreen.main.bounds.size
        var frame = self.btnDone.frame
        
        if frame.origin.y >= screenSize.height {
            frame.origin.y = screenSize.height - 64 - 44
            self.btnDone.frame = frame
        }
    }
    
    private func adjustOnPhoneX() {
        self.vStatusBar.increaseHeight(value: 24)
        self.lbPrivateKey.font = UIFont.boldSystemFont(ofSize: 22)
        self.lbTitle.moveDown(distance: 25)
        self.vContent.moveDown(distance: 50)
        self.vAction.moveDown(distance: 50)
        self.btnDone.moveDown(distance: 50)
    }
    
    private func adjustOnPhone6Plus() {
        //self.btnLogin.moveLeft(distance: 44)
    }
    
    private func adjustOnPhone5S() {
        self.lbTitle.font = UIFont.boldSystemFont(ofSize: 27)
        self.lbPrivateKey.font = UIFont.boldSystemFont(ofSize: 21)
        var frame = self.vQRCode.frame
        frame.size.width = 170
        frame.size.height = 170
        frame.origin.x = (self.vContent.frame.size.width - frame.size.width)/2.0
        self.vQRCode.frame = frame
        self.btnDone.moveUp(distance: 80)
        self.vContent.decreaseHeight(value: 40)
        self.vAction.moveUp(distance: 40)
    }
}
