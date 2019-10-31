//
//  CellFourRows.swift
//  1Pass
//
//  Created by Ngo Lien on 8/6/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import UIKit

class CellTwoRows: RecordBaseCell {
    
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var tf1:UITextField!
    @IBOutlet weak var tf2:UITextField!
    @IBOutlet weak var tf3:UITextField!
    @IBOutlet weak var tf4:UITextField!
    
    @IBOutlet weak var tf5:UITextField!
    @IBOutlet weak var tf6:UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func configureCellData(_ record:Record!) {
        self.record = record
        self.validFields = Utils.getValidFields(record: record)
        self.lbTitle.text = record.title
        self.tf1.text = self.validFields[0].name
        self.tf2.text = self.validFields[1].name
        self.tf3.text = self.validFields[2].name
        self.tf4.text = self.validFields[3].name
        
        guard self.validFields.count >= 5 else {
            self.tf5.superview?.isHidden = true
            self.tf6.superview?.isHidden = true
            return
        }
        self.tf5.text = self.validFields[4].name
        self.tf5.superview?.isHidden = false
        
        guard self.validFields.count == 6 else {
            self.tf6.superview?.isHidden = true
            return
        }
        self.tf6.text = self.validFields[5].name
        self.tf6.superview?.isHidden = false
    }
    
    @IBAction func ibaTappedOnField(field:UIButton!) {
        UIApplication.shared.keyWindow?.endEditing(true)
        // Highlight Field on GUI
        let icon = UIImage(named:"ic-check")?.tint(UIColor.white)
        field.setImage(icon, for: UIControlState.normal)
        field.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 5, 0);
        field.setTitle("Copied", for: UIControlState.normal)
        field.backgroundColor = AppColor.COLOR_COPIED_HUD
        
        // Reset Field State on GUI
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(clearCopyState), userInfo: field, repeats: false)
        
        // Copy to Clipboard
        let tag = field.tag
        UIPasteboard.general.string = self.validFields[tag].value
        
        // Show Copied HUD
        let str = record.title + " / " + self.validFields[tag].name
        (UIApplication.shared.delegate as! AppDelegate).showCopiedHUD(content: str)
        
        // Add to shortcut
        Utils.addRecordToShortcut(recordID: self.record.id)
    }
    
    @objc func clearCopyState(timer:Timer) {
        //let block = {(value: Bool) -> Void in}
        
        if let field = timer.userInfo as? UIButton {
            UIView.animate(withDuration: 1, delay: 0.0, options:[], animations: {
                field.setImage(nil, for: UIControlState.normal)
                field.setTitle("", for: UIControlState.normal)
                field.backgroundColor = UIColor.clear
            }, completion:nil)
        }
    }
    
}
