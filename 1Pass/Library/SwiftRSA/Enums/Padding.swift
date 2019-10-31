//
//  RSAPadding.swift
//  SwiftRSA
//
//  Created by Giacomo Leopizzi on 27/04/2017.
//
//

import Foundation
// import COpenSSL

public extension RSA {
    
    public enum Padding {
        
        case none
        case pkcs1
        case sslv23
        case pkcs1_oaep
        case x931
        
        internal func getPadding() -> Int32 {
            switch self {
            case .none:
                return RSA_NO_PADDING
            case .pkcs1:
                return RSA_PKCS1_PADDING
            case .sslv23:
                return RSA_SSLV23_PADDING
            case .pkcs1_oaep:
                return RSA_PKCS1_OAEP_PADDING
            case .x931:
                return RSA_X931_PADDING
            }
        }
    }
    
}
