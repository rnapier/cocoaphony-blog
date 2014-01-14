---
layout: post
status: publish
published: true
title: NSNotFound
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
wordpress_id: 68
wordpress_url: http://robnapier.net/blog/?p=68
date: 2008-11-17 10:22:52.000000000 -05:00
categories:
- cocoa
tags:
- cocoa
- NSNotFound
---
When faced with the need to return "not found" for something that normally returns an index or other value that would normally be unsigned (whether this is an error condition or a normal event), Cocoa offers the NSNotFound constant as an alternative to returning an illegal index like -1 (which forces you to change the index to an NSInteger, raising the likelihood of sign-based errors if there's ever a long promotion).

NSNotFound is 0x7fffffff, which is not -1 (0xffffffff), but is still very large  (~2 billion) and so should never be a real index for any sanely-sized spaces, and is more readable than -1. NSNotFound is a good constant to remember when these issues come up. Look at NSString -rangeOfString: for an example of its usage.
