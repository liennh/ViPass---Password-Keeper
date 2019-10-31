//
//  SignVerify.swift
//  SwiftRSA
//
//  Created by Giacomo Leopizzi on 06/05/2017.
//
//

import Foundation
// import COpenSSL

extension RSA {
    
    /// Sign a data with the given key.
    ///
    /// - Parameters:
    ///   - data: The data to sign.
    ///   - key: The private key for generating the sign.
    ///   - function: The RSA function of the sign.
    /// - Returns: The sign in a Data object.
    /// - Throws: If there is an error in the process.
    static public func sign(data: Data, withKey key: Key, usingFunction function: Function = .sha256) throws -> Data {
        
        guard let context = EVP_MD_CTX_create() else {
            throw Custom.error(description: OpenSSL.errorDescription)
        }
        
        let keySize = Int(EVP_PKEY_size(key.key))
        var outputBuffer = Data(count: keySize)
        
        let dataPointer = data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in return bytes }
        let pointerOutputBuffer = outputBuffer.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) in return bytes }
    
        
        guard EVP_DigestInit_ex(context, function.evp, nil) == 1 else {
            throw Custom.error(description: OpenSSL.errorDescription)
        }
        
        guard EVP_DigestUpdate(context, UnsafeRawPointer(dataPointer), data.count) == 1 else {
            throw Custom.error(description: OpenSSL.errorDescription)
        }
        
        var outputLength: UInt32 = 0
        
        guard EVP_SignFinal(context, pointerOutputBuffer, &outputLength, key.key) == 1 else {
            throw Custom.error(description: OpenSSL.errorDescription)
        }
        
        return Data(bytes: pointerOutputBuffer, count: Int(outputLength))
        
    }
    
    /// Verify a sign with a given key
    ///
    /// - Parameters:
    ///   - data: The signed data (Data used for generating the signature).
    ///   - signature: The signature of the data.
    ///   - key: The public key for the check.
    ///   - function: The RSA function of the sign.
    /// - Returns: True if the sign is verified, false otherwise.
    /// - Throws: If there is an error in the process.
    static public func verify(data: Data, withSignature signature: Data, usingKey key: Key, withFunction function: Function = .sha256) throws -> Bool {
        OpenSSL.initialize()
        
        guard let context = EVP_MD_CTX_create() else {
            throw Custom.error(description: OpenSSL.errorDescription)
        }

        let dataPointer = data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in return bytes }
        let signaturePointer = signature.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in return bytes }
        
        guard EVP_DigestVerifyInit(context, nil, function.evp, nil, key.key) == 1 else {
            throw Custom.error(description: OpenSSL.errorDescription)
        }
        
        guard EVP_DigestUpdate(context, UnsafeRawPointer(dataPointer), data.count) == 1 else {
            throw Custom.error(description: OpenSSL.errorDescription)
        }
        
        return EVP_DigestVerifyFinal(context, signaturePointer, signature.count) == 1
    }
    
}
