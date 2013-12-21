---
layout: post
status: publish
published: true
title: RNCryptor async
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: "I have completed the major work for RNCryptor asynchronous operations on
  the <a href=\"https://github.com/rnapier/RNCryptor/tree/async\">async branch</a>.
  This changes the API and the file format. I'll be documenting this more formally
  within a few weeks, but here are the high points:\r\n"
wordpress_id: 772
wordpress_url: http://robnapier.net/blog/?p=772
date: 2012-06-24 19:39:43.000000000 -04:00
categories:
- cocoa
tags: []
---
I have completed the major work for RNCryptor asynchronous operations on the <a href="https://github.com/rnapier/RNCryptor/tree/async">async branch</a>. This changes the API and the file format. I'll be documenting this more formally within a few weeks, but here are the high points:
<a id="more"></a><a id="more-772"></a>

There are now separate RNCryptor and RNDecryptor objects (as well as RNOpenSSLEncryptor and RNOpenSSLDecryptor).

Aync usage looks like this:

    RNEncryptor *encryptor = [[RNEncryptor alloc] initWithSettings:kRNCryptorAES256Settings
                                                          password:password
                                                           handler:^(RNCryptor *cryptor, NSData *data) {
                                                              ...
                                                           }];

You add data using `addData:`. `handler` may or may not be called once for every call to `addData:`. When you are done, you must call `finish`, at which point, `handler` will be called one last time. You can check this condition using `cryptor.isFinished`.

There is still synchronous access such as:

    NSData *encryptedData = [RNEncryptor encryptData:data
                                        withSettings:kRNCryptorAES256Settings
                                            password:password
                                               error:&error];

I have dropped all the URL, file and stream APIs. Please let me know if you have a general use case where you would like them. I don't mind creating some convenience methods, but the convenience methods in the original interface were becoming too numerous and that complicates testing. Input on this is welcome. I found that many people were either doing very small things where synchronous NSData is good, or they were using `NSURLConnection`, where you need all the callbacks (to handle redirects, authentication, etc.), so I've supported those two cases the most.

By default, `handler` is called on the GCD queue that the cryptor was created on. You can modify this by setting `responseQueue`.

Input on the API is welcome. I'm leaving it on the async branch until people have time to play with a little bit and I have time to document it fully.
