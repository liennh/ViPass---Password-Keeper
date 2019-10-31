//
//  AddMemberView.swift
//  ViPass
//
//  Created by Ngo Lien on 5/10/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class AddMemberView:UIView, UITextFieldDelegate {
    @IBOutlet weak var vBlur:UIView!
    @IBOutlet weak var tfUsername:UITextField!
    @IBOutlet weak var swAllowToEdit:UISwitch!
    
    
    /*
     let myCustomView: CustomView = UIView.fromNib()
     or
     let myCustomView: CustomView = .fromNib()
     Refer to https://stackoverflow.com/questions/24857986/load-a-uiview-from-nib-in-swift
     */
    class func getFromNib() -> AddMemberView {
        let view:AddMemberView = UIView.fromNib()
        
        // Touch on outside to dismiss
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: view, action: #selector(handleTap))
        tap.cancelsTouchesInView = true
        view.vBlur.addGestureRecognizer(tap)
        
        view.frame = UIScreen.main.bounds
        
        view.adjustGUI()
        return view
    }
    
    @objc func handleTap() {
        self.removeFromSuperview()
    }
    
    // MARK: IBAction
    @IBAction func ibaAdd() {
        UIApplication.shared.keyWindow?.endEditing(true)
        self.dismiss()
    }
    
    // MARK: Public methods
    public func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
        self.tfUsername.becomeFirstResponder()
    }
    
    public func dismiss() {
        self.removeFromSuperview()
    }
    
    // MARK: Private methods
    private func adjustGUI() {
        // Adjust GUI on different screen sizes
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            // self.adjustOnPhone6()
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            //self.adjustOnPhone6Plus()
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.adjustOnPhone5S()
        } else if UIDevice.current.screenType == .iPhoneX {
            //self.adjustOnPhoneX()
        } else if UIDevice.current.screenType == .iPhone4_4S {
            //self.adjustOnPhone4S()
        }
    }
    
    private func adjustOnPhone5S() {
        
    }
    
    // MARK: UITextFieldDelegate
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismiss()
        return true
    }
    
}
