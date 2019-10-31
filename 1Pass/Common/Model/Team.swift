//
//  Team.swift
//  ViPass
//
//  Created by Ngo Lien on 5/9/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import RealmSwift

class Team:NSObject {
    public var name:String! // No encryption, used for search
    public var members:[Member]!
    public var adminID:String! // Username of Admin
}
