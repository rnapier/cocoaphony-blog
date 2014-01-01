---
layout: post
title: "Pinning your SSL Certs"
date: 2014-01-01 15:10:08 -0500
comments: true
categories: 
---
If your app uses SSL to communicate with your server (and it should), you generally don't need to trust [every certificate that Apple trusts](http://support.apple.com/kb/HT5012). You should just trust the specific certificate of your server, or maybe your own root signing certificate. But there's certainly no reason to trust the over 200 certificates in iOS 7's root store.

The practice of trusting only your own certificate is called "pinning," and I've discussed it several times at conferences. I then say something like, "It's easy. [You just do this](https://github.com/rnapier/practical-security/blob/master/SelfCert/SelfCert/Connection.m):"
<!-- more -->
``` objc
...
    NSError *error = NULL;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"www.google.com"
                                                     ofType:@"cer"];
    NSData *certData = [NSData dataWithContentsOfFile:path
                                              options:0
                                                error:&error];
    
    if (! certData) {
      // Handle error reading
    }
    
    SecCertificateRef
    certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData);
    
    if (!certificate) {
      // Handle error parsing
    }
    
    self.anchors = [NSArray arrayWithObject:CFBridgingRelease(certificate)];
...

- (void)connection:(NSURLConnection *)connection
willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {

  SecTrustRef trust = challenge.protectionSpace.serverTrust;
  
  SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef)self.anchors);
  SecTrustSetAnchorCertificatesOnly(trust, true);
  
  SecTrustResultType result;
  OSStatus status = SecTrustEvaluate(trust, &result);
  if (status == errSecSuccess &&
      (result == kSecTrustResultProceed ||
       result == kSecTrustResultUnspecified)) {

    NSURLCredential *cred = [NSURLCredential credentialForTrust:trust];
    [challenge.sender useCredential:cred forAuthenticationChallenge:challenge];
  }
  else {
    [challenge.sender cancelAuthenticationChallenge:challenge];
  }
}
```

I mean, really, what could be simpler. OK, maybe it could be simpler. Maybe if it were a little simpler, everyone would do it. So how about this?

```objc
- (void)connection:(NSURLConnection *)connection
willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  NSString *path = [[NSBundle mainBundle] pathForResource:@"mycert"
                                                   ofType:@"cer"];
  RNPinnedCertValidator *validator = [[RNPinnedCertValidator alloc] initWithCertificatePath:path];
  [validator validateChallenge:challenge];
}
```

Is that simple enough? Then go grab [RNPinnedCertValidator](https://github.com/rnapier/RNPinnedCertValidator).