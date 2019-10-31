//
//  EnterTagsView.swift
//  ViPass
//
//  Created by Ngo Lien on 5/1/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class EnterTagsView:UIView, UITextFieldDelegate {
    @IBOutlet weak var tfTags:UITextField!
    @IBOutlet weak var iconTag:UIImageView!
    var record:Record!
    
    /*
     let myCustomView: CustomView = UIView.fromNib()
     or
     let myCustomView: CustomView = .fromNib()
     Refer to https://stackoverflow.com/questions/24857986/load-a-uiview-from-nib-in-swift
     */
    class func getFromNib() -> EnterTagsView {
        let view:EnterTagsView = UIView.fromNib()
        
        // Icon color
        let icon = view.iconTag
        icon?.image = icon?.image?.tint(UIColor.black)
        view.adjustGUI()
        return view
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        self.record.tags = textField.text
    }
    
    // MARK: UITextFieldDelegate.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // called when 'return' key pressed. return NO to ignore.
        // Hide keyboard
        UIApplication.shared.keyWindow?.endEditing(true)
        return true
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
        } else if Utils.isPad() {
            self.adjustOnPad()
        }
    }
    
    private func adjustOnPad() {
        self.tfTags.font = UIFont.systemFont(ofSize: 22)
    }
    
    private func adjustOnPhone5S() {
        self.tfTags.font = UIFont.systemFont(ofSize: 15)
    }
}
