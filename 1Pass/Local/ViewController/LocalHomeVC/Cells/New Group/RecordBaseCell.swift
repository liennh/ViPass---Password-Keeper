//
//  RecordBaseCell.swift
//  ViPass
//
//  Created by Ngo Lien on 5/1/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class RecordBaseCell:UITableViewCell {
    var record:Record!
    var validFields = [Field]()
    @IBOutlet weak var vContent:UIView!
    
    public func configureCellData(_ record:Record!) {
        // Overwrite inn sub classes
    }
}
