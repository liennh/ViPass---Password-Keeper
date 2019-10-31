//
//  AES-GCM.h
//  ViPass
//
//  Created by Ngo Lien on 5/21/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 Using OpenSSL Universal to Encrypt/Decrypt
 */
@interface AES_GCM : NSObject

// encrypt plaintext.
// key, ivec and tag buffers are required, aad is optional
// depending on your use, you may want to convert key, ivec, and tag to NSData/NSMutableData
+ (BOOL) aes256gcmEncrypt:(NSData*)plaintext
               ciphertext:(NSMutableData**)ciphertext
                      aad:(NSData*)aad
                      key:(const unsigned char*)key
                     ivec:(const unsigned char*)ivec
                      tag:(unsigned char*)tag;

// decrypt ciphertext.
// key, ivec and tag buffers are required, aad is optional
// depending on your use, you may want to convert key, ivec, and tag to NSData/NSMutableData
+ (BOOL) aes256gcmDecrypt:(NSData*)ciphertext
                plaintext:(NSMutableData**)plaintext
                      aad:(NSData*)aad
                      key:(const unsigned char *)key
                     ivec:(const unsigned char *)ivec
                      tag:(unsigned char *)tag;

@end
