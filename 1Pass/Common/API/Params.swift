//
//  AppAPI.swift
//  ViPass
//
//  Created by Ngo Lien on 5/21/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import CryptoSwift

class Params: NSObject {
    public static func forSignUp(user: User) -> [String: Any]? {
        let username = user.username!
        let password = user.masterPassword!
        let secretKey = user.secretKey!

        // Prepare Plain Data
        var accountKey = user.accountKey
        if accountKey == nil {
            accountKey = GenUtils.generateAccountKey()
        }
        
        //let (privateKey, publicKey) = GenUtils.generateUserKeysPairs()!
        Global.shared.srpClient = Client(username: username, password: password)
        let (_, A) = Global.shared.srpClient.startAuthentication() // A:Data
        let s = Data(bytes: try! Random.generate(byteCount: 64)) // Salt  256
        let x = calculate_x(algorithm: .sha1, salt: s, username: username, password: password)
        let v = calculate_v(group: .N1024, x: x) // Verifier

        Global.shared.srpClient.s = s
        Global.shared.srpClient.x = x
        Global.shared.srpClient.v = v

        // Encrypt RSA some items: salt + verifier(v)
        /*let sv = Data(bytes: s.bytes + v.serialize().bytes)
        guard let clientKey = try? RSA.Key(fromPEMPublicKey: Singleton.shared.publicKey) else {
            return nil
        }
        let encSaltVerifier = try? RSA.encrypt(data: sv, withKey: clientKey, usingCipher: .aes_256_cbc)
*/
        // Encrypt AES-GCM 256 accountKey, privateKey for storing
        // Generate aesMasterKey from Master Password + Secret Key
        var aesMasterKey = user.aesMasterKey
        if aesMasterKey == nil {
            aesMasterKey = AppEncryptor.getMasterKey(password: password, secretKey: secretKey)
        }

        guard aesMasterKey != nil else {
            return nil
        }

        user.aesMasterKey = aesMasterKey!

        // Encrypt User Account Key and User Private Key using aesMasterKey
        let encAccountKey = AppEncryptor.encryptAES256(plainData: accountKey!, key: user.aesMasterKey!)
        
        //let encPrivateKey = AppEncryptor.encryptAES256(plainData: privateKey, key: user.aesMasterKey!)

        guard encAccountKey != nil else {
            return nil
        }

        // Update user info
        user.accountKey = accountKey
        
//        user.publicKey = publicKey
//        user.privateKey = privateKey

        // Combine params
        let params = [Keys.i: username,
            Keys.A: A.bytes, // Client Public Key
            Keys.enc_ak: encAccountKey!, // Used to protect User Data
            Keys.s: s.bytes,
            Keys.v: v.serialize().bytes
            //Keys.enc_sv: encSaltVerifier!.bytes, // Used for SRC Auth
            //Keys.pubKey: publicKey, // User Public Key. Used for adding to TEAM
            //Keys.enc_pk: encPrivateKey! // User Private Key. Used to protect TEAM Key
        ] as [String: Any]
        return params
    }
    
    public static func forSetUp(user: User) -> [String: Any]? {
        let username = user.username!
        let password = user.masterPassword!
        let secretKey = user.secretKey!
        
        // Prepare Plain Data
        let accountKey = GenUtils.generateAccountKey()
        
        // Encrypt AES-GCM 256 accountKey, privateKey for storing
        // Generate aesMasterKey from Master Password + Secret Key
        let aesMasterKey = AppEncryptor.getMasterKey(password: password, secretKey: secretKey)
        
        guard aesMasterKey != nil else {
            return nil
        }
        
        user.aesMasterKey = aesMasterKey!
        
        // Encrypt User Account Key and User Private Key using aesMasterKey
        let encAccountKey = AppEncryptor.encryptAES256(plainData: accountKey, key: user.aesMasterKey!)
    
        guard encAccountKey != nil else {
            return nil
        }
        
        // Update user info
        user.accountKey = accountKey
        
        // Combine params
        let params = [Keys.i: username,
            Keys.enc_ak: encAccountKey! // Used to protect User Data
            ] as [String: Any]
        return params
    }

    public static func forLoginFirstStep(user: User) -> [String: Any] {
        let username = user.username!
        let password = user.masterPassword!

        Global.shared.srpClient = Client(username: username, password: password)
        let (_, A) = Global.shared.srpClient.startAuthentication() // A:Data
        return [Keys.i: username,
            Keys.A: A.bytes]
    }

    public static func forLoginLastStep(s: Data, B: Data) -> (Bool, Any) {
        let (ok, msg) = Global.shared.srpClient.processChallenge(salt: s, publicKey: B)
        guard ok else {
            return (false, msg)
        }

        return (true, [Keys.i: Global.shared.srpClient.username,
            Keys.M: Global.shared.srpClient.M?.bytes])
    }
}


