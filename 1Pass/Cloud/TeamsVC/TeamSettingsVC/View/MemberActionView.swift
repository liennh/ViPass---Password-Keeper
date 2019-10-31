//
//  MemberActionView.swift
//  ViPass
//
//  Created by Ngo Lien on 5/10/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class MemberActionView:UIView {
    @IBOutlet weak var vForm:UIView!
    @IBOutlet weak var vOverlay:UIView!
    @IBOutlet weak var btnEditAction:UIButton!
    weak var settingVC:UIViewController!
    var member:Member!
    var currentUser = Global.shared.currentUser
    /*
     let myCustomView: CustomView = UIView.fromNib()
     or
     let myCustomView: CustomView = .fromNib()
     Refer to https://stackoverflow.com/questions/24857986/load-a-uiview-from-nib-in-swift
     */
    class func getFromNib() -> MemberActionView {
        let view:MemberActionView = UIView.fromNib()
        let screenSize = UIScreen.main.bounds.size
        var frame = view.frame
        frame.origin.y = screenSize.height
        frame.size = screenSize
        view.frame = frame
        
        // Dismiss when tap outside
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: view, action: #selector(view.dismiss))
        tap.cancelsTouchesInView = true
        view.vOverlay.addGestureRecognizer(tap)
        
        return view
    }
    
    @IBAction func ibaCancel(sender:UIButton!) {
        self.dismiss()
    }
    
    @IBAction func ibaToggleEditPermission(sender:UIButton!) {
        self.dismiss()
        if self.member.canEdit {
            // "Don't allow to edit"
        } else {
            // "Allow to edit"
            
        }
        
    }
    
    @IBAction func ibaRemoveFromTeam(sender:UIButton!) {
        self.dismiss()

    }
    
    // MARK: Public methods
    func configureViewData(_ member:Member) {
        self.member = member
        if self.member.canEdit {
            self.btnEditAction.setTitle("Don't allow to edit", for: .normal)
        } else {
            self.btnEditAction.setTitle("Allow to edit", for: .normal)
        }
        
    }
    
    func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
        UIView.animate(withDuration: 0.45, delay: 0.0, options:[], animations:{[unowned self] in
            self.moveUp(distance: self.frame.size.height)
            }, completion:{[unowned self] (_) in
                UIView.transition(with: self, duration: 0.01, options: .transitionCrossDissolve, animations: {[unowned self] in
                    self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                    }, completion: nil)
        })
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: 0.25, delay: 0.25, options:[], animations:{[unowned self] in
            self.vForm.moveDown(distance: self.frame.height)
            }, completion:{[unowned self] (_) in
                UIView.transition(with: self, duration: 0.1, options: .transitionCrossDissolve, animations: {[unowned self] in
                    self.backgroundColor = UIColor.clear
                    }, completion: {[unowned self](_) in
                        self.removeFromSuperview()
                })
        })
    }
    
    // MARK: Private methods
    @IBAction func ibaGrayButtonTouchDown(sender:UIButton!) {
        // Higlight background color
        sender.backgroundColor = AppColor.COLOR_GRAY_BUTTON_DOWN
        let textColor = UIColor.white
        sender.titleLabel?.textColor = textColor
        sender.setTitleColor(textColor, for: .normal)
        sender.setTitleColor(textColor, for: .selected)
        sender.setTitleColor(textColor, for: .highlighted)
    }
    
    func grayButtonTouchUp(_ sender:UIButton!) {
        // Higlight background color
        sender.backgroundColor = AppColor.COLOR_GRAY_BUTTON_DOWN
        let textColor = UIColor.white
        sender.titleLabel?.textColor = textColor
        sender.setTitleColor(textColor, for: .normal)
        sender.setTitleColor(textColor, for: .selected)
        sender.setTitleColor(textColor, for: .highlighted)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options:[], animations:{
            sender.backgroundColor = UIColor.clear
            let textColor = AppColor.COLOR_TABBAR_ACTIVE
            sender.titleLabel?.textColor = textColor
            sender.setTitleColor(textColor, for: .normal)
            sender.setTitleColor(textColor, for: .selected)
            sender.setTitleColor(textColor, for: .highlighted)
        }, completion: nil)
    }
}

