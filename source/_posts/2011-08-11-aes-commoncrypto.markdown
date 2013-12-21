---
layout: post
status: publish
published: true
title: Properly encrypting with AES with CommonCrypto
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: Encrypting with AES on OS X and iOS isn't very difficult, but most examples
  do it incorrectly. This article explains how to create a proper salted key, and
  how to generate and manage your IV.
wordpress_id: 564
wordpress_url: http://robnapier.net/blog/?p=564
date: 2011-08-11 16:43:34.000000000 -04:00
categories:
- cocoa
- iphone
- Security
tags: []
---
<strong>Update: You can now download the full example code from my book at <a href="https://github.com/rnapier/ios5ptl/tree/master/ch11/CryptPic/CryptPic">GitHub</a>. This comes from Chapter 11, "Batten the Hatches with Security Services."</strong>

<strong>Update2: The things described here are handled automatically by <a href="https://github.com/rnapier/RNCryptor" target="_blank">RNCryptor</a>, which is an easier approach unless you want to write your own solution.</strong>

I see a lot of example code out there showing how to use `CCCrypt()`, and most of it is unfortunately wrong. Since I just got finished writing about 10 pages of explanation for my upcoming book, I thought I'd post a shortened form here and hopefully help clear things up a little. This is going to be a little bit of a whirlwind, focused on the simplest case. If you want the gory details including performance improvements for large amounts of data, well, <a href="http://www.wiley.com/WileyCDA/WileyTitle/productCd-1119961327.html">the book</a> will be out later this year. :D

<a id="more"></a><a id="more-564"></a>

First and foremost: the key. This is almost always done wrong in the examples you see floating around the Internet. A human-typed password is not an AES key. It has far too little entropy. Using it directly as an AES key opens you up to all kinds of attacks. In particular, lines like this are wrong:

    // DO NOT DO THIS
    NSString *password = @"P4ssW0rd!";
    char keyPtr[kCCKeySizeAES128];
    [password getCString:keyPtr maxLength:sizeof( keyPtr ) encoding:NSUTF8StringEncoding];
    // DO NOT DO THIS

This key is susceptible to a variety of attacks. It is neither salted nor stretched. If `password` is longer than the key size, then the password will be truncated. This is not how you build a key.

First, you need to salt your key. That means adding random data to it so that if the same data is encrypted with the same password, the ciphertext will still be different. The key should then be hashed, so that the final result is the correct length. The correct way to do this is with PKCS #5 (PBKDF2). Unfortunately, prior to 10.7, there wasn't an easy function to do that. I'm going to focus here on 10.7 code, but if you need a simple solution, just add about 8 random characters to the the string, and run it through `-hash`. Stringify that and run it through `-hash` again. Repeat 100,000 times. Take the lower "X" bits where "X" is the number of bits in your key. This isn't perfect, but it's easy to code and close enough. It works on all versions of OS X and iOS. 100,000 times is based on this taking about 100ms for a MacBookPro to calculate in my quick tests. On an iPhone 4, the same delay is around 10,000 iterations. The goal is to force the attacker to waste some time.

(If someone has a better quick-and-easy key generation algorithm, leave a comment.)

But like I said, don't do that way if you can help it. We have PBKDF2 built into `CommonCrypto` now (well, in 10.7). Hand it your salt, your password, the number of iterations, and the length of your key and it spits out the answer for you. I'll show how to do this in the code below.

Did I mention that CommonCrypto is all <a href="http://opensource.apple.com/source/CommonCrypto">open source</a>? So if you needed the PBKDF2 code for other platforms, you could probably get it to work.

OK, now you have a salt. What do you do with it? Save it with the cipertext. You'll need it later to decrypt. The salt is considered public information so you don't need to protect it.

And now the mystical initialization vector (IV) that confuses everyone. In CBC-mode, each 16-byte encryption influences the next 16-byte encryption. This is a good thing. It makes the encryption much stronger. It's also the default. The problem is, what about block 0? The answer is you make up a random block -1. That's the IV.

This is listed as "optional" in `CCCrypt()` which is confusing because it isn't really optional in CBC mode. If you don't provide one, it'll automatically generate an all-0 IV for you. That throws away significant protection on the first block. There's no reason to do that. IV is simple: it's just 16 random bytes. "Save it with the cipertext. You'll need it later to decrypt. The <strike>salt</strike> IV is considered public information so you don't need to protect it."

OK, now that I've gone on and on about theory, let's see this in practice. First, here's how you use it. The method returns the encrypted data (`nil` for error), and returns the IV, salt and error by reference. Slap the data, IV, and salt together in your file in whatever way is easy for you to retrieve them later. The IV has to be 16 bytes long for AES. The salt can be any length, but my code sets it to 8 bytes, which is the PKCS#5 minimum recommended length.

    NSData *iv;
    NSData *salt;
    NSError *error;
    NSData *encryptedData = [RNCryptManager encryptedDataForData:plaintextData
                                                        password:password
                                                              iv:&iv
                                                            salt:&salt
                                                           error:&error];

And here's the code. I will leave the decrypt method as an exercise for the reader. It's almost identical, and it's a good idea to actually understand this code, not just copy it. Don't forget to link `Security.framework`.

Go forth and encrypt stuff.

    #import <CommonCrypto/CommonCryptor.h>
    #import <CommonCrypto/CommonKeyDerivation.h>

    NSString * const
    kRNCryptManagerErrorDomain = @"net.robnapier.RNCryptManager";

    const CCAlgorithm kAlgorithm = kCCAlgorithmAES128;
    const NSUInteger kAlgorithmKeySize = kCCKeySizeAES128;
    const NSUInteger kAlgorithmBlockSize = kCCBlockSizeAES128;
    const NSUInteger kAlgorithmIVSize = kCCBlockSizeAES128;
    const NSUInteger kPBKDFSaltSize = 8;
    const NSUInteger kPBKDFRounds = 10000;  // ~80ms on an iPhone 4

    // ===================

    + (NSData *)encryptedDataForData:(NSData *)data
                            password:(NSString *)password
                                  iv:(NSData **)iv
                                salt:(NSData **)salt
                               error:(NSError **)error {
      NSAssert(iv, @"IV must not be NULL");
      NSAssert(salt, @"salt must not be NULL");
      
      *iv = [self randomDataOfLength:kAlgorithmIVSize];
      *salt = [self randomDataOfLength:kPBKDFSaltSize];
      
      NSData *key = [self AESKeyForPassword:password salt:*salt];
      
      size_t outLength;
      NSMutableData *
      cipherData = [NSMutableData dataWithLength:data.length +
                    kAlgorithmBlockSize];

      CCCryptorStatus
      result = CCCrypt(kCCEncrypt, // operation
                       kAlgorithm, // Algorithm
                       kCCOptionPKCS7Padding, // options
                       key.bytes, // key
                       key.length, // keylength
                       (*iv).bytes,// iv
                       data.bytes, // dataIn
                       data.length, // dataInLength,
                       cipherData.mutableBytes, // dataOut
                       cipherData.length, // dataOutAvailable
                       &outLength); // dataOutMoved

      if (result == kCCSuccess) {
        cipherData.length = outLength;
      }
      else {
        if (error) {
          *error = [NSError errorWithDomain:kRNCryptManagerErrorDomain
                                       code:result
                                   userInfo:nil];
        }
        return nil;
      }
      
      return cipherData;
    }

    // ===================

    + (NSData *)randomDataOfLength:(size_t)length {
      NSMutableData *data = [NSMutableData dataWithLength:length];
      
      int result = SecRandomCopyBytes(kSecRandomDefault, 
                                      length,
                                      data.mutableBytes);
      NSAssert(result == 0, @"Unable to generate random bytes: %d",
               errno);
      
      return data;
    }

    // ===================

    // Replace this with a 10,000 hash calls if you don't have CCKeyDerivationPBKDF
    + (NSData *)AESKeyForPassword:(NSString *)password 
                             salt:(NSData *)salt {
      NSMutableData *
      derivedKey = [NSMutableData dataWithLength:kAlgorithmKeySize];
      
      int 
      result = CCKeyDerivationPBKDF(kCCPBKDF2,            // algorithm
                                    password.UTF8String,  // password
                                    [password lengthOfBytesUsingEncoding:NSUTF8StringEncoding],  // passwordLength
                                    salt.bytes,           // salt
                                    salt.length,          // saltLen
                                    kCCPRFHmacAlgSHA1,    // PRF
                                    kPBKDFRounds,         // rounds
                                    derivedKey.mutableBytes, // derivedKey
                                    derivedKey.length); // derivedKeyLen
      
      // Do not log password here
      NSAssert(result == kCCSuccess,
               @"Unable to create AES key for password: %d", result);
      
      return derivedKey;
    }
