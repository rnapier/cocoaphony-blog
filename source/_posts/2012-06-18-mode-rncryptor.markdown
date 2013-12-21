---
layout: post
status: publish
published: true
title: Mode changes for RNCryptor
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: After several feature requests, much consideration, and a long chat with
  the security engineering team at Apple, I've decided to make a change to the default
  AES mode used by RNCryptor from its current CTR to the much more ubiquitous CBC.
wordpress_id: 767
wordpress_url: http://robnapier.net/blog/?p=767
date: 2012-06-18 19:37:41.000000000 -04:00
categories:
- cocoa
tags: []
---
After several feature requests, much consideration, and a long chat with the security engineering team at Apple, I've decided to make a change to the default AES mode used by RNCryptor from its current CTR to the much more ubiquitous CBC.

CTR mode has several advantages that I was hoping to exploit. First, it does not require padding, so it is not subject to padding oracle attacks (the cipher text is also generally a few bytes shorter than the equivalent CBC). That said, if the same nonce+counter+key combination is ever reused, an attacker can easily compute the key. This is pretty unlikely given how RNCryptor generates its nonce, but it's not impossible. If the same IV+key is used for CBC mode, then some information is leaked to an attacker, but its not nearly as catastrophic as reusing a nonce. The point is that CTR is not a home run here. It's different, exchanging one possible vulnerability for a different one (since RNCryptor does not store previous nonces to prevent reuse).

It is also possible to compute CTR in parallel on multiple cores. Apple doesn't currently do this, and is not highly likely to do so in the future. They might, but it's not something to adapt the design to.

Almost every AES system out there implements CBC, so using any other mode introduces a significant interoperability problem. A mode would need to be dramatically better to be worth that. CTR has not lived up to that requirement, and so I'm switching to CBC.

This will make it much easier to write RNCryptor-compatible modules in Java, JavaScript, etc., as have been requested.

Possibly most importantly, this change gets us closer to making RNCryptor compatible back to iOS 4.0, and Mac OS X 10.4. I still have to consider `CCKeyDerivationPBKDF`.

If you update, note that this is incompatible with your existing encrypted files. I doubt there is enough field usage out there that this is an issue, but if it is, let me know and I can discuss with you how to convert.
