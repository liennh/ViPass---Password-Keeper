//
//  EncryptDecrypt.swift
//  SwiftRSA
//
//  Created by Giacomo Leopizzi on 27/04/2017.
//
//

// import COpenSSL
import Foundation

extension RSA {
    
    /// Encrypt a data object using EVP.
    ///
    /// - Parameters:
    ///   - data: The data to encrypt.
    ///   - key: The RSA for performing the encryption.
    ///   - cipher: The cipher to use for the encryption.
    ///   - padding: Padding for the RSA encryption (Optional).
    /// - Returns: The encrypted data.
    /// - Throws: A RSAKeyError object.
    static public func encrypt(data: Data, withKey key: Key, usingCipher cipher: Cipher, padding: Padding? = nil) throws -> Data {
        
        guard let context = EVP_CIPHER_CTX_new() else {
            throw Custom.error(description: OpenSSL.errorDescription)
        }
        
        defer {
            EVP_CIPHER_CTX_free(context)
        }
        
        if let padding = padding {
            EVP_CIPHER_CTX_set_padding(context, padding.getPadding())
        }
        
        // ---> PREPARATION FOR EVP_SealInit
        
        // Preparation for the simmetric key
        let sizeSimmetricKey = EVP_PKEY_size(key.key).toInt()
        var simmetricKeyBuffer = Data(count: sizeSimmetricKey)
        
        var pointerSimmetricKey: UnsafeMutablePointer<UInt8>? = simmetricKeyBuffer.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) in return bytes }
        var lenghtSimmetricKey: Int32 = 0 // After the EVP_SealInit it will contain the lenght of the simmetric key
        
        // Preparation for the iv buffer
        let sizeIVBuffer = EVP_CIPHER_iv_length(cipher.getCipher()).toInt()
        var ivBuffer = Data(count: sizeIVBuffer)
     
        let pointerIVBuffer = ivBuffer.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) in return bytes }
        
        // Get reference to the asimmetric key
        var pointerAsimmetricKey: UnsafeMutablePointer<EVP_PKEY>? = key.key
        
        
        guard EVP_SealInit(context, cipher.getCipher(), &pointerSimmetricKey, &lenghtSimmetricKey, pointerIVBuffer, &pointerAsimmetricKey, 1) != 0 else {
            throw Custom.error(description: "An error occurred in EVP_SealInit")
        }
        
        // ---> PREPARATION FOR EVP_EncryptUpdate
        
        let plaintextBufferPointer = data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in return bytes }
        let plaintextLenght = data.count
        let cipherBlockLenght = EVP_CIPHER_block_size(cipher.getCipher()).toInt()
        var writtenBytes: Int32 = 0 // After the EVP_EncryptUpdate it will contain the number of bytes written to outBuffer
        
        let calculatedOutputLenght = plaintextLenght + cipherBlockLenght - (plaintextLenght % cipherBlockLenght)
        
        var outputBuffer = Data(count: calculatedOutputLenght)
        
        let pointerOutputBuffer = outputBuffer.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) in return bytes }
        
        guard EVP_EncryptUpdate(context, pointerOutputBuffer, &writtenBytes, plaintextBufferPointer, plaintextLenght.toCInt()) == 1 else {
            throw Custom.error(description: "An error occurred in EVP_EncryptUpdate")
        }
        
        // ---> PREPARATION FOR EVP_SealFinal
        
        var finalWrittenBytes: Int32 = 0
        
        guard EVP_SealFinal(context, pointerOutputBuffer.advanced(by: writtenBytes.toInt()), &finalWrittenBytes) == 1 else {
            throw Custom.error(description: "An error occurred in EVP_SealFinal")
        }
        

        return EncryptedBundle(encryptedPayload: outputBuffer, encryptedSimmetricKey: simmetricKeyBuffer, iv: ivBuffer).toContinuosData()
        
    }
    
    /// Decrypt an EncryptedBundle obejct using EVP.
    ///
    /// - Parameters:
    ///   - bundle: The bundle to decrypt.
    ///   - key: The private key for the decryption.
    ///   - cipher: The cipher used for the encryption.
    ///   - padding: Padding for the RSA encryption (Optional).
    /// - Returns: The decrypted data.
    /// - Throws: A RSAKeyError object.
    static public func decrypt(data: Data, withKey key: Key, usingCipher cipher: Cipher, padding: Padding? = nil) throws -> Data {
        
        guard let bundle = EncryptedBundle(fromData: data, usingCipher: cipher) else {
            throw Custom.error(description: "Invalid data input")
        }
        
        guard let context = EVP_CIPHER_CTX_new() else {
            throw Custom.error(description: OpenSSL.errorDescription)
        }
        
        defer {
            EVP_CIPHER_CTX_free(context)
        }
        
        if let padding = padding {
            EVP_CIPHER_CTX_set_padding(context, padding.getPadding())
        }
        
        var simmetricKey = Data(bundle.encryptedSimmetricKey)
        var iv = Data(bundle.iv)
        var encryptedPayload = Data(bundle.encryptedPayload)
        
        let simmetricKeyPointer = simmetricKey.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) in return bytes }
        let ivPointer = iv.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) in return bytes }
        
        guard EVP_OpenInit(context, cipher.getCipher(), simmetricKeyPointer, bundle.encryptedSimmetricKey.count.toCInt(), ivPointer, key.key) != 0 else {
            throw Custom.error(description: OpenSSL.errorDescription)
        }
        
        let payloadPointer = encryptedPayload.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) in return bytes }
        
        var outputBuffer = Data(count: bundle.encryptedPayload.count)
        
        let outputBufferPointer = outputBuffer.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) in return bytes }
        
        var writtenBytes: Int32 = 0
        
        guard EVP_DecryptUpdate(context, outputBufferPointer, &writtenBytes, payloadPointer, bundle.encryptedPayload.count.toCInt()) == 1 else {
            throw Custom.error(description: OpenSSL.errorDescription)
        }
        
        var finalWrittenBytes: Int32 = 0
        
        guard EVP_OpenFinal(context, outputBufferPointer.advanced(by: writtenBytes.toInt()), &finalWrittenBytes) == 1 else {
            throw Custom.error(description: OpenSSL.errorDescription)
        }
        
        let finalLenght = writtenBytes.toInt() + finalWrittenBytes.toInt()
        
        return Data(bytes: outputBufferPointer.deinitialize(), count: finalLenght)
    }
    
}
