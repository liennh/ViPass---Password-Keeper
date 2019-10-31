//
//  Error.swift
//  SwiftRSA
//
//  Created by Giacomo Leopizzi on 06/05/2017.
//
//

import Foundation

extension RSA {
    
    /// Custom error for RSA
    ///
    /// - error: The error that occur
    public enum Custom: Error {
        case error(description: String)
    }
    
}
