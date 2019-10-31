//
//  AddMoreField.swift
//  ViPass
//
//  Created by Ngo Lien on 5/2/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class AddNewField:UIView {
    @IBOutlet weak var vAdd:UIView!
    @IBOutlet weak var lbAdd:UILabel!
    @IBOutlet weak var iconAdd:UIImageView!
    
   // weak var localAddRecordVC:Loc
    
    /*
     let myCustomView: CustomView = UIView.fromNib()
     or
     let myCustomView: CustomView = .fromNib()
     Refer to https://stackoverflow.com/questions/24857986/load-a-uiview-from-nib-in-swift
     */
    class func getFromNib() -> AddNewField {
        let view:AddNewField = UIView.fromNib()
        
        // Round button
        let vButton = view.vAdd
        vButton?.layer.cornerRadius = Constant.Button_Corner_Radius
        vButton?.layer.borderWidth = 1.0
        vButton?.layer.borderColor = AppColor.COLOR_TABBAR_ACTIVE.cgColor
        vButton?.backgroundColor = UIColor.clear
        
        
        // Icon color
        view.iconAdd.image = view.iconAdd.image?.tint(AppColor.COLOR_TABBAR_ACTIVE)
        
        // Adjust GUI
        view.adjustGUI()
        return view
    }
    
    @IBAction func ibaButtonAddTouchDown() {
        self.vAdd.backgroundColor = AppColor.COLOR_TABBAR_ACTIVE
        self.lbAdd.textColor = UIColor.white
        self.iconAdd.image = self.iconAdd.image?.tint(UIColor.white)
    }
    
    @IBAction func ibaAddNewField() {
        // Notify View Controller
        NotificationCenter.default.post(name: .Add_New_Field, object: nil, userInfo: nil)
        
        // Higlight background color
        self.vAdd.backgroundColor = AppColor.COLOR_TABBAR_ACTIVE
        UIView.animate(withDuration: 0.5, delay: 0.0, options:[], animations:{ [unowned self] in
            self.vAdd.backgroundColor = UIColor.clear
            self.lbAdd.textColor = AppColor.COLOR_TABBAR_ACTIVE
            self.iconAdd.image = self.iconAdd.image?.tint(AppColor.COLOR_TABBAR_ACTIVE)
        }, completion: nil)
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
        self.lbAdd.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        self.iconAdd.moveLeft(distance: 30)
    }
    
    private func adjustOnPhone5S() {
        self.iconAdd.moveLeft(distance: 15)
    }
}

