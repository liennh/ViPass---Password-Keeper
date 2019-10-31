//
//  Cipher.swift
//  SwiftRSA
//
//  Created by Paolo Currò on 02/05/2017.
//
//
import Foundation
// import COpenSSL

public extension RSA {
    
    public enum Cipher {
        
        case des_ecb
        case des_ede
        case des_ede3
        case des_ede_ecb
        case des_ede3_ecb
        case des_cfb64
        
        case des_cfb1
        case des_cfb8
        case des_ede_cfb64
        
        case des_ede3_cfb64
        
        case des_ede3_cfb1
        case des_ede3_cfb8
        case des_ofb
        case des_ede_ofb
        case des_ede3_ofb
        case des_cbc
        case des_ede_cbc
        case des_ede3_cbc
        case desx_cbc
        case des_ede3_wrap
        
        case rc4
        case rc4_40
        
        case rc4_hmac_md5
        
        case idea_ecb
        case idea_cfb64
        
        case idea_ofb
        case idea_cbc
        
        case rc2_ecb
        case rc2_cbc
        case rc2_40_cbc
        case rc2_64_cbc
        case rc2_cfb64
        
        case rc2_ofb
        
        case bf_ecb
        case bf_cbc
        case bf_cfb64
        
        case bf_ofb
        
        case cast5_ecb
        case cast5_cbc
        case cast5_cfb64
        
        case cast5_ofb
        
        case aes_128_ecb
        case aes_128_cbc
        case aes_128_cfb1
        case aes_128_cfb8
        case aes_128_cfb128
        
        case aes_128_ofb
        case aes_128_ctr
        case aes_128_ccm
        case aes_128_gcm
        case aes_128_xts
        case aes_128_wrap
        case aes_192_ecb
        case aes_192_cbc
        case aes_192_cfb1
        case aes_192_cfb8
        case aes_192_cfb128
        
        case aes_192_ofb
        case aes_192_ctr
        case aes_192_ccm
        case aes_192_gcm
        case aes_192_wrap
        case aes_256_ecb
        case aes_256_cbc
        case aes_256_cfb1
        case aes_256_cfb8
        case aes_256_cfb128
        
        case aes_256_ofb
        case aes_256_ctr
        case aes_256_ccm
        case aes_256_gcm
        case aes_256_xts
        case aes_256_wrap
        
        case aes_128_cbc_hmac_sha1
        case aes_256_cbc_hmac_sha1
        
        case aes_128_cbc_hmac_sha256
        case aes_256_cbc_hmac_sha256
        
        case camellia_128_ecb
        case camellia_128_cbc
        case camellia_128_cfb1
        case camellia_128_cfb8
        case camellia_128_cfb128
        
        case camellia_128_ofb
        case camellia_192_ecb
        case camellia_192_cbc
        case camellia_192_cfb1
        case camellia_192_cfb8
        case camellia_192_cfb128
        
        case camellia_192_ofb
        case camellia_256_ecb
        case camellia_256_cbc
        case camellia_256_cfb1
        case camellia_256_cfb8
        case camellia_256_cfb128
        
        case camellia_256_ofb
        
        case seed_ecb
        case seed_cbc
        case seed_cfb128
        
        case seed_ofb
        
        internal func getCipher() ->  UnsafePointer<EVP_CIPHER>! {
            switch self {
            case .des_ecb:
                return EVP_des_ecb()
            case .des_ede:
                return EVP_des_ede()
            case .des_ede3:
                return EVP_des_ede3()
            case .des_ede_ecb:
                return EVP_des_ede_ecb()
            case .des_ede3_ecb:
                return EVP_des_ede3_ecb()
            case .des_cfb64:
                return EVP_des_cfb64()
                
            case .des_cfb1:
                return EVP_des_cfb1()
            case .des_cfb8:
                return EVP_des_cfb8()
            case .des_ede_cfb64:
                return EVP_des_ede_cfb64()
                
            case .des_ede3_cfb64:
                return EVP_des_ede3_cfb64()
                
            case .des_ede3_cfb1:
                return EVP_des_ede3_cfb1()
            case .des_ede3_cfb8:
                return EVP_des_ede3_cfb8()
            case .des_ofb:
                return EVP_des_ofb()
            case .des_ede_ofb:
                return EVP_des_ede_ofb()
            case .des_ede3_ofb:
                return EVP_des_ede3_ofb()
            case .des_cbc:
                return EVP_des_cbc()
            case .des_ede_cbc:
                return EVP_des_ede_cbc()
            case .des_ede3_cbc:
                return EVP_des_ede3_cbc()
            case .desx_cbc:
                return EVP_desx_cbc()
            case .des_ede3_wrap:
                return EVP_des_ede3_wrap()
                
                /*
                 * This should now be supported through the dev_crypto ENGINE. But also, why
                 * are rc4 and md5 declarations made here inside a "NO_DES" precompiler
                 * branch?
                 */
                
            case .rc4:
                return EVP_rc4()
            case .rc4_40:
                return EVP_rc4_40()
                
            case .rc4_hmac_md5:
                return EVP_rc4_hmac_md5()
                
            case .idea_ecb:
                return EVP_idea_ecb()
            case .idea_cfb64:
                return EVP_idea_cfb64()
                
            case .idea_ofb:
                return EVP_idea_ofb()
            case .idea_cbc:
                return EVP_idea_cbc()
                
            case .rc2_ecb:
                return EVP_rc2_ecb()
            case .rc2_cbc:
                return EVP_rc2_cbc()
            case .rc2_40_cbc:
                return EVP_rc2_40_cbc()
            case .rc2_64_cbc:
                return EVP_rc2_64_cbc()
            case .rc2_cfb64:
                return EVP_rc2_cfb64()
                
            case .rc2_ofb:
                return EVP_rc2_ofb()
                
            case .bf_ecb:
                return EVP_bf_ecb()
            case .bf_cbc:
                return EVP_bf_cbc()
            case .bf_cfb64:
                return EVP_bf_cfb64()
                
            case .bf_ofb:
                return EVP_bf_ofb()
                
            case .cast5_ecb:
                return EVP_cast5_ecb()
            case .cast5_cbc:
                return EVP_cast5_cbc()
            case .cast5_cfb64:
                return EVP_cast5_cfb64()
                
            case .cast5_ofb:
                return EVP_cast5_ofb()
                
            case .aes_128_ecb:
                return EVP_aes_128_ecb()
            case .aes_128_cbc:
                return EVP_aes_128_cbc()
            case .aes_128_cfb1:
                return EVP_aes_128_cfb1()
            case .aes_128_cfb8:
                return EVP_aes_128_cfb8()
            case .aes_128_cfb128:
                return EVP_aes_128_cfb128()
                
            case .aes_128_ofb:
                return EVP_aes_128_ofb()
            case .aes_128_ctr:
                return EVP_aes_128_ctr()
            case .aes_128_ccm:
                return EVP_aes_128_ccm()
            case .aes_128_gcm:
                return EVP_aes_128_gcm()
            case .aes_128_xts:
                return EVP_aes_128_xts()
            case .aes_128_wrap:
                return EVP_aes_128_wrap()
            case .aes_192_ecb:
                return EVP_aes_192_ecb()
            case .aes_192_cbc:
                return EVP_aes_192_cbc()
            case .aes_192_cfb1:
                return EVP_aes_192_cfb1()
            case .aes_192_cfb8:
                return EVP_aes_192_cfb8()
            case .aes_192_cfb128:
                return EVP_aes_192_cfb128()
                
            case .aes_192_ofb:
                return EVP_aes_192_ofb()
            case .aes_192_ctr:
                return EVP_aes_192_ctr()
            case .aes_192_ccm:
                return EVP_aes_192_ccm()
            case .aes_192_gcm:
                return EVP_aes_192_gcm()
            case .aes_192_wrap:
                return EVP_aes_192_wrap()
            case .aes_256_ecb:
                return EVP_aes_256_ecb()
            case .aes_256_cbc:
                return EVP_aes_256_cbc()
            case .aes_256_cfb1:
                return EVP_aes_256_cfb1()
            case .aes_256_cfb8:
                return EVP_aes_256_cfb8()
            case .aes_256_cfb128:
                return EVP_aes_256_cfb128()
                
            case .aes_256_ofb:
                return EVP_aes_256_ofb()
            case .aes_256_ctr:
                return EVP_aes_256_ctr()
            case .aes_256_ccm:
                return EVP_aes_256_ccm()
            case .aes_256_gcm:
                return EVP_aes_256_gcm()
            case .aes_256_xts:
                return EVP_aes_256_xts()
            case .aes_256_wrap:
                return EVP_aes_256_wrap()
                
            case .aes_128_cbc_hmac_sha1:
                return EVP_aes_128_cbc_hmac_sha1()
            case .aes_256_cbc_hmac_sha1:
                return EVP_aes_256_cbc_hmac_sha1()
                
            case .aes_128_cbc_hmac_sha256:
                return EVP_aes_128_cbc_hmac_sha256()
            case .aes_256_cbc_hmac_sha256:
                return EVP_aes_256_cbc_hmac_sha256()
                
            case .camellia_128_ecb:
                return EVP_camellia_128_ecb()
            case .camellia_128_cbc:
                return EVP_camellia_128_cbc()
            case .camellia_128_cfb1:
                return EVP_camellia_128_cfb1()
            case .camellia_128_cfb8:
                return EVP_camellia_128_cfb8()
            case .camellia_128_cfb128:
                return EVP_camellia_128_cfb128()
                
            case .camellia_128_ofb:
                return EVP_camellia_128_ofb()
            case .camellia_192_ecb:
                return EVP_camellia_192_ecb()
            case .camellia_192_cbc:
                return EVP_camellia_192_cbc()
            case .camellia_192_cfb1:
                return EVP_camellia_192_cfb1()
            case .camellia_192_cfb8:
                return EVP_camellia_192_cfb8()
            case .camellia_192_cfb128:
                return EVP_camellia_192_cfb128()
                
            case .camellia_192_ofb:
                return EVP_camellia_192_ofb()
            case .camellia_256_ecb:
                return EVP_camellia_256_ecb()
            case .camellia_256_cbc:
                return EVP_camellia_256_cbc()
            case .camellia_256_cfb1:
                return EVP_camellia_256_cfb1()
            case .camellia_256_cfb8:
                return EVP_camellia_256_cfb8()
            case .camellia_256_cfb128:
                return EVP_camellia_256_cfb128()
                
            case .camellia_256_ofb:
                return EVP_camellia_256_ofb()
                
            case .seed_ecb:
                return EVP_seed_ecb()
            case .seed_cbc:
                return EVP_seed_cbc()
            case .seed_cfb128:
                return EVP_seed_cfb128()
                
            case .seed_ofb:
                return EVP_seed_ofb()
            }
        }
    }
    
}
