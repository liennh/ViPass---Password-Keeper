//
//  Int-Extension.swift
//  SwiftRSA
//
//  Created by Giacomo Leopizzi on 27/04/2017.
//
//

import Foundation

internal extension Int {
    
    
    /// Convert an Int to a CInt
    ///
    /// - Returns: The CInt
    func toCInt() -> CInt {
        return CInt(self)
    }
    
}
