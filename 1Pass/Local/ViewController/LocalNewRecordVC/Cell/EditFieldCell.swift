//
//  EditFieldCell.swift
//  ViPass
//
//  Created by Ngo Lien on 5/1/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class EditFieldCell:UITableViewCell, UITextFieldDelegate { 
    @IBOutlet weak var tfName:UITextField!
    @IBOutlet weak var tfValue:UITextField!
    @IBOutlet weak var vContent:UIView!
    @IBOutlet weak var iconDelete:UIImageView!
    @IBOutlet weak var iconCopy:UIImageView!
    @IBOutlet weak var iconGenerate:UIImageView!
    @IBOutlet weak var vCopied:UIButton!
    
    weak var record:Record?
    var field:Field!
    var index:IndexPath!
    let vGenerator = GeneratorView.getFromNib()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconDelete.image = self.iconDelete.image?.tint(UIColor.black)
        self.iconGenerate.image = self.iconGenerate.image?.tint(UIColor.black)
        self.iconCopy.image = self.iconCopy.image?.tint(UIColor.black)
        
        if Utils.isPad() {
            self.tfName.font = UIFont.boldSystemFont(ofSize: 22)
            self.tfValue.font = UIFont.systemFont(ofSize: 22)
        }
    }
    
    public func configureCellData(_ field:Field) {
        self.field = field
        self.tfName.text = field.name
        self.tfValue.text = field.value
        
        // Fix bug when add new field
        self.tfValue.layer.borderWidth = 0
        self.tfName.layer.borderWidth = 0
        /////
        
        if self.tfValue.text?.count == 0 {
            self.iconGenerate.superview?.superview?.bringSubview(toFront: (self.iconGenerate.superview)!)
        } else {
            self.iconCopy.superview?.superview?.bringSubview(toFront: (self.iconCopy.superview)!)
        }
        
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        if textField.tag == 0 {
            self.field.name = textField.text //.trim()
        } else {
            self.field.value = textField.text //?.trim()
        }
        
        // remove Red border
        textField.layer.borderWidth = 0
    }
    
    @IBAction func ibaGenerateRandomValue() {
        UIApplication.shared.keyWindow?.endEditing(true)
        self.vGenerator.resetDefaultValue()
        self.vGenerator.editFieldCell = self
        self.vGenerator.show()
    }
    
    @IBAction func ibaCopy() {
        UIApplication.shared.keyWindow?.endEditing(true)
        // Copy to Clipboard
        UIPasteboard.general.string = self.field.value
        self.userDidCopy(field: self.vCopied)
    }
    
    @IBAction func ibaDelete() {
        if((self.tfName.text?.count == 0) && (self.tfValue.text?.count == 0)) {
            // Go to delete this field
            NotificationCenter.default.post(name: .Delete_Field, object: nil, userInfo: [Keys.index: self.index])
        } else {
            UIApplication.shared.keyWindow?.endEditing(true)
            // Ask user before deleting
            let confirm = ConfirmView.getFromNib(title: "Are you sure you want to delete this field?", confirm: "Delete", cancel: "Cancel")
            confirm.confirmAction = {
                DispatchQueue.main.async { [unowned self] in
                    NotificationCenter.default.post(name: .Delete_Field, object: nil, userInfo: [Keys.index: self.index])
                }
            }
            confirm.cancelAction = {} // Do nothing
            confirm.show()
        }
    }
    
    // MARK: Public methods
    public func didGenerateRandomValue(_ value: String) {
        self.tfValue.text = value
        self.field.value = value
        
        self.textFieldDidEndEditing(self.tfValue)
    }
    
    // MARK: UITextFieldDelegate.
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if Utils.isPad() {
           // NotificationCenter.default.post(name: .Keyboard_Hidden, object: nil, userInfo: [Keys.textField: textField])
        }
        return true
    }
    
    ////
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if( (textField != self.tfName) && (self.tfName.text?.count == 0) ) {
            textField.resignFirstResponder()
            self.tfName.becomeFirstResponder()
            return false
        }
        
        if Utils.isPad() {
          //  NotificationCenter.default.post(name: .Keyboard_Shown, object: nil, userInfo: [Keys.textField: textField])
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.tfValue {
            let view = self.iconGenerate.superview
            view?.superview?.bringSubview(toFront: view!)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if ((textField == self.tfValue) && (self.tfValue.text?.length != 0)) {
            let view = self.iconCopy.superview
            view?.superview?.bringSubview(toFront: view!)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // called when 'return' key pressed. return NO to ignore.
        // Hide keyboard
        UIApplication.shared.keyWindow?.endEditing(true)
        return true
    }
    
    // MARK: Highlight copy
    private func userDidCopy(field:UIButton!) {
        // Highlight Field on GUI
        field.superview?.bringSubview(toFront: field)
        let icon = UIImage(named:"ic-check")?.tint(UIColor.white)
        field.setImage(icon, for: UIControlState.normal)
        field.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 5, 0);
        field.setTitle("Copied", for: UIControlState.normal)
        field.backgroundColor = AppColor.COLOR_COPIED_HUD
        
        // Reset Field State on GUI
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(clearCopyState), userInfo: field, repeats: false)
        
        // Show Copied HUD
        var str = Utils.getString(self.field.name)
        if str.count == 0 {
            str = self.tfValue.text!
        }
        (UIApplication.shared.delegate as! AppDelegate).showCopiedHUD(content: str)
        
        // Add record to shortcut if needed
        if self.record != nil {
            Utils.addRecordToShortcut(recordID: self.record!.id)
        }
    }
    
    @objc func clearCopyState(timer:Timer) {
        if let field = timer.userInfo as? UIButton {
            let block = {(value: Bool) -> Void in
                field.superview?.sendSubview(toBack: field)
            }
            UIView.animate(withDuration: 1, delay: 0.0, options:[], animations: {
                field.setImage(nil, for: UIControlState.normal)
                field.setTitle("", for: UIControlState.normal)
                field.backgroundColor = UIColor.clear
            }, completion:block)
        }
    }
}
