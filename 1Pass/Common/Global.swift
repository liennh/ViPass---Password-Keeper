//
//  Global.swift
//  ViPass
//
//  Created by Ngo Lien on 6/13/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation

class Global:NSObject {
    
    var currentUser:User?
    var srpClient:Client!
    var customURL:String? // temporary
    var customApiKey:String? // temporary
    var allowSync:Bool = true // temporary
    
    public static let shared: Global = {
        return Global()
    }()

    override init() {
        super.init()
        
    }
    
}
