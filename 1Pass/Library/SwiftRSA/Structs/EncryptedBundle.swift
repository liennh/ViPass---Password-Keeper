//
//  EncryptedBundle.swift
//  SwiftRSA
//
//  Created by Giacomo Leopizzi on 27/04/2017.
//
//

import Foundation
// import COpenSSL

extension RSA {
    
    
    /// Bundle that encapsulate an encrypted data
    internal struct EncryptedBundle {
        
        /// The encrypted data
        public let encryptedPayload: Data
        
        /// The encrypted symetric key
        public let encryptedSimmetricKey: Data
        
        /// The init vector of the encryption
        public let iv: Data

    }
    
}

internal extension RSA.EncryptedBundle {
    
    func toContinuosData() -> Data {
        
        return Data.join(data: [encryptedSimmetricKey, iv, encryptedPayload])
    }
    
    init?(fromData data: Data, usingCipher cipher: RSA.Cipher) {
        
        guard let dataArray = Data.disjoin(data: data), dataArray.count == 3 else {
            return nil
        }

        self.init(encryptedPayload: dataArray[2], encryptedSimmetricKey: dataArray[0], iv: dataArray[1])
    }
    
}
