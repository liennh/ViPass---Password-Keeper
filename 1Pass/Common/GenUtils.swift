//
//  GenUtils.swift
//  ViPass
//
//  Created by Ngo Lien on 5/16/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
//import CatCrypto
import CryptoSwift


class GenUtils:NSObject {
    public static func generateRandomValue(length: Int) -> String {
        let lowercase = "abcdefghijklmnopqrstuvwxyz"
        let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let number = "0123456789"
        let specialChar = AppConfig.SpecialChars
        
        let allowedChars = lowercase + specialChar + uppercase + number
        
        // Generate Random Value from allowedChars
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""
        
        for _ in 0..<length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
    
    public static func generateIV() -> [UInt8] {
        return generateRandomBytes(length:16)
    }
    
    public static func generateAccountKey() -> [UInt8] {
        return generateRandomBytes(length:32)
    }
    
    public static func generateTeamKey() -> [UInt8] {
        return generateRandomBytes(length:32)
    }
    
    public static func generateRandomBytes(length:Int) -> [UInt8] {
        var key = Data(count: length)
        let result = key.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, length, bytes)
        }
        if result == errSecSuccess {
            return key.bytes
        } else {
            DDLog("Problem generating random bytes")
            return GenUtils.generateRandomValue(length: length).toData().bytes
        }
    }
    
    public static func generateRandomData(length:Int) -> Data {
        var key = Data(count: length)
        let result = key.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, length, bytes)
        }
        if result == errSecSuccess {
            return key
        } else {
            DDLog("Problem generating random data")
            return GenUtils.generateRandomValue(length: length).toData()
        }
    }
    
    // Return (privateKey, publicKey)
    public static func generateUserKeysPairs() -> ([UInt8], [UInt8])? {
        let key: RSA.Key = RSA.Key.generate(keyPairWithLenght: 2048)
        return (key.privateKey?.bytes, key.publicKey?.bytes) as? ([UInt8], [UInt8])
    }
    
}
