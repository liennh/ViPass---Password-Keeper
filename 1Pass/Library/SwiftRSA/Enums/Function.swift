//
//  Function.swift
//  SwiftRSA
//
//  Created by Giacomo Leopizzi on 06/05/2017.
//
//

import Foundation
// import COpenSSL

extension RSA {
    
    public enum Function {
        
        case md5
        case sha1
        case sha224
        case sha256
        case sha384
        case sha512
        
        internal var evp: UnsafePointer<EVP_MD> {
            switch self {
            case .md5:
                return EVP_md5()
            case .sha1:
                return EVP_sha1()
            case .sha224:
                return EVP_sha224()
            case .sha256:
                return EVP_sha256()
            case .sha384:
                return EVP_sha384()
            case .sha512:
                return EVP_sha512()
            }
        }
        
    }
    
}
