//
//  AddMemberCell.swift
//  ViPass
//
//  Created by Ngo Lien on 5/10/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class AddMemberCell: UITableViewCell {
    @IBOutlet weak var iconAdd:UIImageView!
    @IBOutlet weak var lbTitle:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconAdd.image = self.iconAdd.image?.tint(AppColor.COLOR_TABBAR_ACTIVE)
    }
}
