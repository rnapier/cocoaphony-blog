---
layout: post
title: "RNCryptor: Truncating Passwords"
date: 2013-12-30 21:30:11 -0500
comments: true
categories: rncryptor security
---

**Summary: If there is any chance that your RNCryptor passwords include multi-byte characters (Chinese, for example), you really need to upgrade to RNCryptor 2.2 when it comes out this week.**

I hate it when I do stupid things. But then you all get to learn something, so luckily some good can come of my shame. Please learn something so this isn't all for naught.

[Issue #77](https://github.com/rnapier/RNCryptor/issues/77) in RNCryptor is one of those classic bugs. Here it is, as gently pointed out to me by [Arthur Walasek](https://github.com/arthurwalasek):

``` objc
int result = CCKeyDerivationPBKDF(keySettings.PBKDFAlgorithm,      // algorithm
                   password.UTF8String, // password
                   password.length, // passwordLength
                   ...
```

I have had this bug since I first wrote this code for iOS 5 PTL, and it's horrible. The problem, if you haven't seen it yet, is that `-length` returns the number of characters in `password`, not the number of bytes. In many languages you can get away with that, but not in multi-byte languages like Chinese.
<!-- more -->
So what happens when someone uses the password "中文密码"? `password.UTF8String` returns 8 bytes, but `password.length` returns 4. So we truncate this password down to "中文" (2 characters, 4 bytes) and that's what we use. That means later, you can decrypt this with anything that's half-right. "中文xx" is good enough.

The fix is simple. You can either use `-lengthOfBytesUsingEncoding:`, or you can create an `NSData` with `-dataUsingEncoding:`. I prefer the latter, and [that's how I've fixed it](https://github.com/rnapier/RNCryptor/commit/2c3cae0e677c1aa4d841b655c82bcb0d4086bd60).

The tricky bit is maintaining backward compatibility. It requires bumping the file version so we can tell which approach we used. But all of that is done and checked in.

Right now, I'm working with [Curtis Farnham](https://github.com/curtisdf) to make sure that the PHP version is compatible with the latest changes. This bug convinced me to finally write some test vectors so we can keep all the language implementations consistent. Once I get that straightened out, I'll post a new version of RNCryptor (or by the end of the week either way).