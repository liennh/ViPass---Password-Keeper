//
//  Key.swift
//  SwiftRSA
//
//  Created by Giacomo Leopizzi on 06/05/2017.
//
//

import Foundation
// import COpenSSL

extension RSA {
    
    /// Represent a key (public, private or both) in Swift.
    public class Key {
        
        internal var key: UnsafeMutablePointer<EVP_PKEY>
        
        /// Try to extract the public key.
        public var publicKey: String? {
            get {
                do {
                    var io = try RSAIO()
                    
                    guard PEM_write_bio_PUBKEY(io.bio, key) == 1 else {
                        return nil
                    }
                    
                    let rawBufferCapacity = io.pending
                    let rawBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: rawBufferCapacity)
                    defer {
                        rawBuffer.deallocate(capacity: rawBufferCapacity)
                    }
                    
                    _ = try io.read(into: UnsafeMutableBufferPointer(start: rawBuffer, count: rawBufferCapacity))
                    
                    let data = Data(buffer: UnsafeMutableBufferPointer(start: rawBuffer, count: rawBufferCapacity))
                    let bytes = data.filter({ _ in true })
                    return bytes.reduce("", { $0 + String(UnicodeScalar($1)) })
                    
                } catch {
                    print(error.localizedDescription)
                    return nil
                }
            }
        }
        
        // Try to extract the private key.
        public var privateKey: String? {
            get {
                do {
                    var io = try RSAIO()
                    
                    guard (PEM_write_bio_PrivateKey(io.bio, key, nil, nil, 0, nil, nil) == 1) else {
                        return nil
                    }
                    let rawBufferCapacity = io.pending
                    let rawBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: rawBufferCapacity)
                    defer {
                        rawBuffer.deallocate(capacity: rawBufferCapacity)
                    }
                    
                    _ = try io.read(into: UnsafeMutableBufferPointer(start: rawBuffer, count: rawBufferCapacity))
                    
                    let data = Data(buffer: UnsafeMutableBufferPointer(start: rawBuffer, count: rawBufferCapacity))
                    let bytes = data.filter({ _ in true })
                    return bytes.reduce("", { $0 + String(UnicodeScalar($1)) })
                    
                } catch {
                    print(error.localizedDescription)
                    return nil
                }
            }
        }
        
        
        private init(key: UnsafeMutablePointer<EVP_PKEY>) {
            OpenSSL.initialize()
            self.key = key
        }
        
        convenience private init(io: RSAIO) throws {
            guard let key = PEM_read_bio_PrivateKey(io.bio, nil, nil, nil) else {
                throw Custom.error(description: OpenSSL.errorDescription)
            }
            
            self.init(key: key)
        }
        
        /// Create a new key from a PEM format private key.
        ///
        /// - Parameter pemKey: The private key string.
        /// - Throws: If an error occur during the creation.
        convenience public init(fromPEMPrivateKey pemKey: String) throws {
            try self.init(io: RSAIO(buffer: pemKey))
        }
        
        /// Create a new key from a PEM format public key.
        ///
        /// - Parameter pemKey: The public key string.
        /// - Throws: If an error occur during the creation.
        convenience public init(fromPEMPublicKey pemKey: String) throws {
            let io = try RSAIO(buffer: pemKey)
            
            guard let key = PEM_read_bio_PUBKEY(io.bio, nil, nil, nil) else {
                throw Custom.error(description: OpenSSL.errorDescription)
            }
            
            self.init(key: key)
        }
        
        deinit {
            EVP_PKEY_free(key)
        }
        
        
        /// Generate a new pair of RSA keys.
        ///
        /// - Parameter length: The lenght of the key. Default 2048.
        /// - Returns: The generated keys.
        public static func generate(keyPairWithLenght length: Int32 = 2048) -> Key {
            let key = Key(key: EVP_PKEY_new())
            let rsa = RSA_new()
            let exponent = BN_new()
            BN_set_word(exponent, 0x10001)
            RSA_generate_key_ex(rsa, length, exponent, nil)
            EVP_PKEY_set1_RSA(key.key, rsa)
            return key
        }
        
    }
    
}
