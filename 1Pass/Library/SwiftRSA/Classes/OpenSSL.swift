//
//  OpenSSL.swift
//  SwiftRSA
//
//  Created by Giacomo Leopizzi on 06/05/2017.
//
//

// import COpenSSL
import Foundation

final internal class OpenSSL {
    
    static private var initialized = false
    
    static func initialize() {
        guard !initialized else { return }
        SSL_library_init()
        SSL_load_error_strings()
        ERR_load_crypto_strings()
        //OPENSSL_config(nil)
    }
    
    static var errorDescription: String {
        let error = ERR_get_error()
        if let string = ERR_reason_error_string(error) {
            return String(validatingUTF8: string) ?? "Unknown Error"
        } else {
            return "Unknown Error"
        }
    }
    
    
}
