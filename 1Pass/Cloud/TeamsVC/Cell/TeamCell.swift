//
//  TeamCell.swift
//  ViPass
//
//  Created by Ngo Lien on 5/9/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class TeamCell: UITableViewCell {
    @IBOutlet weak var lbName:UILabel!
    @IBOutlet weak var vContent:UIView!
    var team:Team!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func configureCellData(_ team:Team) {
        self.lbName.text = team.name
        self.team = team
    }
}
