//
//  PremiumVC.swift
//  1Pass
//
//  Created by Ngo Lien on 8/20/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import UIKit
import MessageUI
import SwiftyStoreKit

class PremiumVC: BaseVC, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var lbPrice:UILabel!
    @IBOutlet weak var vStatusBar:UIView!
    @IBOutlet weak var vBottom:UIView!
    @IBOutlet weak var btnGoPremium:UIButton!
    
    var fromSettings:Bool = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default //.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbPrice.isHidden = true
        let screenSize = UIScreen.main.bounds.size
        if Utils.isPad() {
            self.scrollView.contentSize = CGSize(width: screenSize.width, height: 920)
        } else {
            self.scrollView.contentSize = CGSize(width: screenSize.width, height: 1067)
        }
        
        self.adjustGUI()
        self.getProductInfo()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    private func getProductInfo() {
        let productID = AppConfig.Yearly_Subscription_Product_ID
        SwiftyStoreKit.retrieveProductsInfo([productID]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                self.lbPrice.text = "Just \(priceString) per year."
                self.lbPrice.isHidden = false
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                DDLog("Invalid product identifier: \(invalidProductId)")
            }
            else {
                DDLog("Error: \(String(describing: result.error))")
            }
        }
    }
    
    private func close() {
        self.hideLoading()
        if self.fromSettings {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func ibaShowPrivacy() {
        self.view.endEditing(true)
        let vc = InappWebView(nibName: "InappWebView", bundle: nil)
        vc.title = "Privacy Policy"
        let url = URL(string: AppConfig.URL_Privacy_Policy)
        vc.url = url
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func ibaShowTermsOfUse() {
        self.view.endEditing(true)
        let vc = InappWebView(nibName: "InappWebView", bundle: nil)
        vc.title = "Terms of Service"
        let url = URL(string: AppConfig.URL_Terms_Of_Use)
        vc.url = url
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func ibaGoPremium(sender:UIButton!) {
        self.view.endEditing(true)
        self.defaultButtonTouchUp(sender)
        
        guard Utils.isNetworkConnected() else {
            // Show Alert
            let alert = AlertView.getFromNib(title: "No Internet Connection.")
            alert.show()
            
            self.close()
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        //DDLog("ibaGoPremium")
        let productId = AppConfig.Yearly_Subscription_Product_ID
        SwiftyStoreKit.purchaseProduct(productId, atomically: true) { [unowned self] result in
            DDLog("result: \(result)")
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                let sharedSecret = AppConfig.Inapp_Purchase_Shared_Secret
                let appleValidator = AppleReceiptValidator(service: .production, sharedSecret:  sharedSecret)
                SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: true) { [unowned self] result in
                    
                    if case .success(let receipt) = result {
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                            ofType: .autoRenewable,
                            productId: productId,
                            inReceipt: receipt)
                        
                        switch purchaseResult {
                        case .purchased(let expiryDate, let receiptItems):
                            DDLog("Product is valid until \(expiryDate)")
                            // Update Expired date
                            InappPurchase.setAccountType(1) // Premium
                            InappPurchase.updateLocal(expiredAt: expiryDate)
                            InappPurchase.updateServer(expiredAt: expiryDate)
                            
                            let dateString = dateFormatter.string(from: expiryDate)
                            
                            // Show Alert
                            let alert = AlertView.getFromNib(title: "ViPass Premium is valid until \(dateString).\n\nThank you for your support!")
                            alert.show()
                            
                            // close this screen
                            self.close()
                            
                        case .expired(let expiryDate, let receiptItems):
                            DDLog("Product is expired since \(expiryDate)")
                            
                            let dateString = dateFormatter.string(from: expiryDate)
                            
                            // Show Alert
                            let alert = AlertView.getFromNib(title: "ViPass Premium has expired since \(dateString).")
                            alert.show()
                            
                        case .notPurchased:
                            DDLog("This product has never been purchased")
                            // Show Alert
                            let alert = AlertView.getFromNib(title: "ViPass Premium has never been purchased.")
                            alert.show()
                        }
                        
                    } else {
                        // receipt verification error
                        DDLog("receipt verification error")
                        // Show Alert
                        let alert = AlertView.getFromNib(title: "Receipt verification error.")
                        alert.show()
                    }
                }
            } else {
                // purchase error
                DDLog("purchase error")
                // Show Alert
                let alert = AlertView.getFromNib(title: "Purchase failed.")
                alert.show()
            }
        }
    }
    
    //Restore previous purchases
    @IBAction func ibaRestore() {
        self.view.endEditing(true)
        
        guard Utils.isNetworkConnected() else {
            // Show Alert
            let alert = AlertView.getFromNib(title: "No Internet Connection.")
            alert.show()
            
            self.close()
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        SwiftyStoreKit.restorePurchases(atomically: true) { [unowned self] results in
            if results.restoreFailedPurchases.count > 0 {
                DDLog("Restore Failed: \(results.restoreFailedPurchases)")
            
                let alert = AlertView.getFromNib(title: "Restore failed.")
                alert.show()
                
                self.close()
            }
            else if results.restoredPurchases.count > 0 {
                DDLog("Restore Success: \(results.restoredPurchases)")
                // Refresh Receipt and Update Expiry Date
                let productId = AppConfig.Yearly_Subscription_Product_ID
                let sharedSecret = AppConfig.Inapp_Purchase_Shared_Secret
                let appleValidator = AppleReceiptValidator(service: .production, sharedSecret:  sharedSecret)
                SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: true) { [unowned self] result in

                    if case .success(let receipt) = result {
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                            ofType: .autoRenewable,
                            productId: productId,
                            inReceipt: receipt)
                        
                        switch purchaseResult {
                        case .purchased(let expiryDate, let receiptItems):
                            DDLog("Product is valid until \(expiryDate)")
                            // Update Expired date
                            InappPurchase.setAccountType(1) // Premium
                            InappPurchase.updateLocal(expiredAt: expiryDate)
                            InappPurchase.updateServer(expiredAt: expiryDate)
                            
                            let dateString = dateFormatter.string(from: expiryDate)
                            
                            // Show Alert
                            let alert = AlertView.getFromNib(title: "ViPass Premium is valid until \(dateString).\n\nThank you for your support!")
                            alert.show()
                            
                        case .expired(let expiryDate, let receiptItems):
                            DDLog("Product is expired since \(expiryDate)")
                            InappPurchase.setAccountType(1) // Premium
                            InappPurchase.updateLocal(expiredAt: expiryDate)
                            
                            let dateString = dateFormatter.string(from: expiryDate)
                            
                            // Show Alert
                            let alert = AlertView.getFromNib(title: "ViPass Premium has expired since \(dateString).")
                            alert.show()
                        case .notPurchased:
                            DDLog("This product has never been purchased")
                            // Show Alert
                            let alert = AlertView.getFromNib(title: "ViPass Premium has never been purchased.")
                            alert.show()
                        }
                        
                    } else {
                        // receipt verification error
                        DDLog("receipt verification error")
                        // Show Alert
                        let alert = AlertView.getFromNib(title: "Receipt verification error.")
                        alert.show()
                    }
                    
                    self.close()
                }
                // Show FULL FEATURES here
            }
            else {
                DDLog("Nothing to Restore")
                
                // Show Alert
                let alert = AlertView.getFromNib(title: "Nothing to Restore.")
                alert.show()
                
                self.close()
            }
        }
    }
    
    @IBAction func ibaContactTeam(sender:UIButton!) {
        self.grayButtonTouchUp(sender)
        guard MFMailComposeViewController.canSendMail() else {
            let alert = AlertView.getFromNib(title: "Mail services are not available.")
            alert.show()
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients(["info@1pass.vn"])
        composeVC.setSubject("Feedback about \(AppConfig.App_Name)")
        composeVC.setMessageBody("", isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        switch result {
        case .sent:
            GoogleWearAlert.showAlert(title: "Sent!", .success)
        case .saved:
            GoogleWearAlert.showAlert(title: "Saved!", .success)
        case .failed:
            GoogleWearAlert.showAlert(title: "Failed!", .success)
        default:
            let _ = 1
        }
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Private methods
    private func adjustGUI() {
        self.btnGoPremium.layer.cornerRadius = Constant.Button_Corner_Radius
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            //self.adjustOnPhone6()
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
        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        // do nothing. see PremiumPAD xib file
    }
    
    private func adjustOnPhone5S() {
        let screenSize = UIScreen.main.bounds.size
        self.scrollView.contentSize = CGSize(width: screenSize.width, height: 1100)
    }
    
    private func adjustOnPhoneX() {
        self.vStatusBar.increaseHeight(value: 24)
        self.vBottom.moveUp(distance: 44)
        self.scrollView.decreaseHeight(value: 44)
    }
}
