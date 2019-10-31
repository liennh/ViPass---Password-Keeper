//
//  ConfirmView.swift
//  ViPass
//
//  Created by Ngo Lien on 5/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class ConfirmView:UIView {
    @IBOutlet weak var btnTitle:UIButton!
    @IBOutlet weak var vAlert:UIView!
    @IBOutlet weak var vBlur:UIView!
    @IBOutlet weak var btnOK:UIButton!
    @IBOutlet weak var btnCancel:UIButton!
    var confirmAction:VoidBlock!
    var cancelAction:VoidBlock!
    
    
    /*
     let myCustomView: CustomView = UIView.fromNib()
     or
     let myCustomView: CustomView = .fromNib()
     Refer to https://stackoverflow.com/questions/24857986/load-a-uiview-from-nib-in-swift
     */
    class func getFromNib(title:String, confirm:String, cancel:String) -> ConfirmView {
        let view:ConfirmView = UIView.fromNib()
        view.frame = UIScreen.main.bounds
        view.btnOK.layer.cornerRadius = view.btnOK.frame.size.height/2.0
        
        // Calculate height of title
        let fontLight = UIFont.systemFont(ofSize: 20.0, weight: .light)
        let width = view.vAlert.frame.size.width - 32 // (16 + 16)
        let height = title.heightWithConstrainedWidth(width, font: fontLight)
        
        var frame = view.vAlert.frame
        frame.size.height = height! + 126 + 10 // 126 is button OK, Cancel + Padding
        frame.origin.y = (view.frame.size.height - frame.size.height)/2.0
        view.vAlert.frame = frame
        
        view.vAlert.layer.cornerRadius = 10
        
        view.btnTitle.setTitle(title, for: .normal)
        view.btnOK.setTitle(confirm, for: .normal)
        view.btnCancel.setTitle(cancel.uppercased(), for: .normal)
        
        return view
    }
    
    @objc func handleTap() {
        self.dismiss()
    }
    
    // IBAction
    @IBAction func ibaOK(button:UIButton!) {
        if self.confirmAction != nil {
            self.confirmAction()
        }
        self.dismiss()
    }
    
    @IBAction func ibaCancel(button:UIButton!) {
        if self.cancelAction != nil {
            self.cancelAction()
        }
        self.dismiss()
    }
    
    func show(inView:UIView) {
        inView.addSubview(self)
    }
    
    func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    func dismiss() {
        self.removeFromSuperview()
    }
    
}
