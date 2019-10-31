//
//  MemberCell.swift
//  ViPass
//
//  Created by Ngo Lien on 5/10/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class MemberCell: UITableViewCell {
    @IBOutlet weak var lbName:UILabel!
    var member:Member!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func configureCellData(_ member:Member) {
        self.lbName.text = member.username
        self.member = member
    }
}
