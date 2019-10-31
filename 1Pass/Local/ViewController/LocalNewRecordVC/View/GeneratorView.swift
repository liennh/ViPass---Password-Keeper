//
//  GeneratorView.swift
//  ViPass
//
//  Created by Ngo Lien on 5/3/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class GeneratorView:UIView {
    @IBOutlet weak var vBlur:UIView!
    @IBOutlet weak var vForm:UIView!
    @IBOutlet weak var lbRandomValue:UILabel!
    @IBOutlet weak var lbCount:UILabel!
    @IBOutlet weak var lbTitle:UILabel!
    
    @IBOutlet weak var swLowercase:UISwitch!
    @IBOutlet weak var swUppercase:UISwitch!
    @IBOutlet weak var swNumber:UISwitch!
    @IBOutlet weak var swSpecialChar:UISwitch!
    @IBOutlet weak var slider:UISlider!
    @IBOutlet weak var iconLightning:UIImageView!
    
    weak var editFieldCell:EditFieldCell!
    
    /*
     let myCustomView: CustomView = UIView.fromNib()
     or
     let myCustomView: CustomView = .fromNib()
     Refer to https://stackoverflow.com/questions/24857986/load-a-uiview-from-nib-in-swift
     */
    class func getFromNib() -> GeneratorView {
        let view:GeneratorView = UIView.fromNib()
        
        // Touch on outside to dismiss
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: view, action: #selector(handleTap))
        tap.cancelsTouchesInView = false
        view.vBlur.addGestureRecognizer(tap)
       
        // Init default random value
        let defaultCount = Int(view.slider.value)
        view.lbRandomValue.text = view.generateRandomValue(length: defaultCount)
        view.lbCount.text = "\(defaultCount)"
        view.frame = UIScreen.main.bounds
        
        view.adjustGUI()
        return view
    }
    
    @objc func handleTap() {
        self.dismiss()
    }
    
    // MARK: IBAction
    @IBAction func sliderValueChanged(sender: UISlider) {
        let currentValue = Int(sender.value)
        self.lbCount.text = "\(currentValue)"
        self.lbRandomValue.text = self.generateRandomValue(length: currentValue)
    }
    
    @IBAction func switchChanged(mySwitch: UISwitch) {
        self.lbRandomValue.text = self.generateRandomValue(length: Int(self.slider.value))
    }
    
    @IBAction func ibaUse() {
        if self.editFieldCell != nil {
            self.editFieldCell.didGenerateRandomValue(self.lbRandomValue.text!)
        }
        self.dismiss()
    }
    
    // MARK: Public methods
    public func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    public func dismiss() {
        self.removeFromSuperview()
    }
    
    public func resetDefaultValue() {
        self.swLowercase.isOn = true
        self.swUppercase.isOn = true
        self.swNumber.isOn = true
        self.swSpecialChar.isOn = false
        self.slider.value = 20
        self.sliderValueChanged(sender: self.slider)
    }
    
    // MARK: Private methods
    private func generateRandomValue(length: Int) -> String {
        let lowercase = "abcdefghijklmnopqrstuvwxyz"
        let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let number = "0123456789"
        let specialChar = "!@#$%^&*()_-=+{}['~`]|;:,./?><"
        
        var allowedChars = ""
        
        // Check status of switch
        if self.swLowercase.isOn {
            allowedChars += lowercase
        }
        
        if self.swSpecialChar.isOn {
            allowedChars += specialChar
        }
        
        if self.swUppercase.isOn {
            allowedChars += uppercase
        }
        
        if self.swNumber.isOn {
            allowedChars += number
        }
        
        if allowedChars.count == 0 {
            return ""
        }
        
        // Generate Random Value from allowedChars
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""
        
        for _ in 0..<length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
    
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
        let screenSize = UIScreen.main.bounds.size
        var frame = self.vForm.frame
        frame.size.width = 450
        frame.origin.x = (screenSize.width - frame.size.width)/2.0
        self.vForm.frame = frame
        
        self.lbTitle.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    private func adjustOnPhone5S() {
        self.iconLightning.moveLeft(distance: 30)
    }
    
}
