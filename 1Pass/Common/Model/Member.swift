//
//  Member.swift
//  ViPass
//
//  Created by Ngo Lien on 5/10/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class Member:NSObject {
    public var username:String!
    public var avatar:String?
    public var canEdit:Bool! = false
    
    public weak var team:Team!
    
    // True if the one created the Team
    public func isAdmin() -> Bool {
        if self.team.adminID == self.username {
            return true
        }
        return false
    }
}

