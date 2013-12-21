---
layout: post
status: publish
published: true
title: RNCryptor and my Titanium experiment
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: "Several months ago, I received a request to port my <a href=\"https://github.com/rnapier/RNCryptor\">RNCryptor</a>
  module to <a href=\"http://www.appcelerator.com\">Titanium</a>. I've never been
  a fan of the JavaScript wrappers for iOS and Android. My belief and experience is
  that they're far more trouble than their worth. But the goal of RNCryptor was always
  to help people use AES correctly, and that's as important in JavaScript as it is
  in Objective-C. So I wrapped up RNCyptor into a Titanium module and stuck it on
  the <a href=\"https://marketplace.appcelerator.com\">Appcelerator Marketplace</a>.
  Though RNCryptor is free, the pain of wrapping it into JavaScript led me to charge
  $10 for the Titanium version.\r\n\r\nThe pain of maintaining this thing has gotten
  to be too much, though. I'm releasing it today on <a href=\"https://github.com/rnapier/Cryptor-titanium\">GitHub</a>
  in its current form, which is based on the older, synchronous form of RNCryptor.
  I may not have updated all the license text yet; if I miss any, it is under the
  MIT license. Thanks to those who purchased Cryptor-Titanium during its commercial
  life. Anyone who is interested in continuing development, please contact me (or
  submit a pull request).\r\n\r\n"
wordpress_id: 794
wordpress_url: http://robnapier.net/blog/?p=794
date: 2012-08-21 10:13:18.000000000 -04:00
categories:
- iphone
- Security
tags: []
---
Several months ago, I received a request to port my <a href="https://github.com/rnapier/RNCryptor">RNCryptor</a> module to <a href="http://www.appcelerator.com">Titanium</a>. I've never been a fan of the JavaScript wrappers for iOS and Android. My belief and experience is that they're far more trouble than their worth. But the goal of RNCryptor was always to help people use AES correctly, and that's as important in JavaScript as it is in Objective-C. So I wrapped up RNCyptor into a Titanium module and stuck it on the <a href="https://marketplace.appcelerator.com">Appcelerator Marketplace</a>. Though RNCryptor is free, the pain of wrapping it into JavaScript led me to charge $10 for the Titanium version.

The pain of maintaining this thing has gotten to be too much, though. I'm releasing it today on <a href="https://github.com/rnapier/Cryptor-titanium">GitHub</a> in its current form, which is based on the older, synchronous form of RNCryptor. I may not have updated all the license text yet; if I miss any, it is under the MIT license. Thanks to those who purchased Cryptor-Titanium during its commercial life. Anyone who is interested in continuing development, please contact me (or submit a pull request).

<a id="more"></a><a id="more-794"></a>Trying to upgrade to the new asynchronous interface is what led me to throw my hands up in disgust. The JavaScript isn't hard. Obviously JavaScript is fully capable of managing an asynchronous interface. It's all the shim nonsense and the constant impedance mismatches. And the sheer punch-me-in-the-face annoyance of debugging JavaScript on the iPhone.

Note that RNCryptor has always been an iOS-only solution, so the Titanium wrapper only works on iOS. If you want a correctly-written, cross-platform JavaScript solution, my recommendation is <a href="http://bitwiseshiftleft.github.com/sjcl">SJCL</a>.

My experience here has strengthened my belief that the JavaScript shims for mobile development are bad in theory and horrible in practice. It is much easier to write a full iOS app and a full Android app than to try to write one app that runs well on both. JavaScript only makes it harder.
