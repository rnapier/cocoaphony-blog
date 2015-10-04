---
layout: post
title: "RNCryptor v4"
date: 2015-10-04 12:38:36 -0400
comments: true
categories: rncryptor
---
After months of writing and rewriting, I am happy to finally announce [RNCryptor 4 beta 1](https://github.com/RNCryptor/RNCryptor/releases/tag/RNCryptor-4.0.0-beta.1) in Swift.

RNCryptor 4 is a complete rewrite of RNCryptor for Swift 2 with full bridging support to Objective-C. It has a streamlined API, simpler installation, and improved internals. It continues to use the [v3 data format](https://github.com/RNCryptor/RNCryptor-Spec/blob/master/RNCryptor-Spec-v3.md) and is fully interoperable with [other RNCryptor implementations](https://github.com/RNCryptor).
<!-- more -->

For users desiring a fully Objective-C solution, [v3](https://github.com/RNCryptor/RNCryptor/releases/tag/RNCryptor-3.0.1) is still available. I don't currently plan to do significant new work on v3, but will consider it if there is strong interest. Going forward, I expect most OS X and iOS projects to be able to accept a mix of ObjC and Swift code. Objective-C continues to be a fully supported language in RNCryptor 4.

I plan to convert this to a final release in a week or so if no major issues are discovered.

I now move onto:

* Continuing to prepare for [dotSwift](http://www.dotswift.io).
* Getting back to the blog. 
* RNCryptor v5, which will finally update the data format to improve performance, security, and robustness. Much of the v4 design was specifically to make v5 easier to write.