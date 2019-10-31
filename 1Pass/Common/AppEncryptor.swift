//
//  ViPassEncryptor.swift
//  ViPass
//
//  Created by Ngo Lien on 5/16/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import CryptoSwift

class AppEncryptor: NSObject {
    public class func getSessionKey(bytes: [UInt8]) -> [UInt8] {
        // Generate sessionKey from 20 bytes in SRP.
        let sessionKey = try! PKCS5.PBKDF2(password: bytes, salt: bytes, iterations: 1, variant: .sha256).calculate()

        return sessionKey // 32 in length
    }
    
    public class func getMasterKey(password: String, secretKey: String) -> [UInt8]? {
        let secretBytes = secretKey.toData().bytes
        let thePassword = password.toData().bytes + secretBytes
        // Generate aesMasterKey from Master Password + Hash of Private Key
        let aesMasterKey = try? PKCS5.PBKDF2(password: thePassword, salt: secretBytes, iterations: 4096, variant: .sha256).calculate()
        
        return aesMasterKey
    }

    /*
     key: Must be 32 in length.
     algorithsm: AES-256 CBC mode
     return: [UInt8] if succeeded: [16 iv bytes, data bytes]
     return nil if failed to encrypt
    */
    public class func encryptAES256(plainData: [UInt8], key: [UInt8]) -> [UInt8]? {
        let iv = GenUtils.generateRandomBytes(length: 16) // 16 in length is for CBC mode
        do {
            let cbc = CBC(iv: iv)
            let aes = try AES(key: key, blockMode: cbc, padding: .pkcs5)
            let encrypted = try aes.encrypt(plainData)
            return iv + encrypted
        }
        catch {
            return nil
        }
        
        /*
        // In combined mode, the authentication tag is directly appended to the encrypted message. This is usually what you want.
        let iv = GenUtils.generateRandomBytes(length: 12) // 12 in length is perfect
        do {
            let gcm = GCM(iv: iv, mode: .combined)
            let aes = try AES(key: key, blockMode: gcm, padding: .noPadding)
            let encrypted = try aes.encrypt(plainData)
            // let tag = gcm.authenticationTag   // not used due to combined mode. Auth Tag is attached to encrypted result
            return iv + encrypted
        }
        catch {
            return nil
        }*/
    }

    /*
     key: Must 32 in length.
     algorithsm: AES-256 CBC mode
     return Plain data or nil, if there is an error
     */
    public class func decryptAES256(cipheredBytes: [UInt8], key: [UInt8]) -> [UInt8]? {
        let iv = Array(cipheredBytes[0..<16])
        let encrypted = Array(cipheredBytes[16..<(cipheredBytes.count)])
        do {
            let cbc = CBC(iv: iv)
            let aes = try AES(key: key, blockMode: cbc, padding: .pkcs5)
            let decrypted = try aes.decrypt(encrypted)
            guard decrypted.count < encrypted.count  else {
                return nil
            }
            return decrypted
        } catch {
            return nil
        }
        
        /*let iv = Array(cipheredBytes[0..<12])
        let encrypted = Array(cipheredBytes[12..<(cipheredBytes.count)])
        do {
            let decGCM = GCM(iv: iv, mode: .combined)
            let aes = try AES(key: key, blockMode: decGCM, padding: .noPadding)
            return try aes.decrypt(encrypted)
        } catch {
            return nil
        }*/
    }
}
