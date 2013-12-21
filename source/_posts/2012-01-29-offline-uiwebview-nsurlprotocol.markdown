---
layout: post
status: publish
published: true
title: Drop-in offline caching for UIWebView (and NSURLProtocol)
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: Your programs need to deal gracefully with being offline. Mugunth Kumar has
  built an excellent toolkit that manages REST connections while offline called MKNetworkKit,
  and Chapter 17 of our book is devoted to the ins-and-outs of this subject. But sometimes
  you just have a simple UIWebView, and you want to cache the last version of the
  page.  In this article you'll learn how to implement this using NSURLProtocol
wordpress_id: 588
wordpress_url: http://robnapier.net/blog/?p=588
date: 2012-01-29 14:56:11.000000000 -05:00
categories:
- cocoa
- iphone
tags: []
---
*The most up-to-date source for this is now available at <a href="https://github.com/rnapier/RNCachingURLProtocol">github</a>.*

Your programs need to deal gracefully with being offline. Mugunth Kumar has built an excellent toolkit that manages REST connections while offline called <a href="https://github.com/MugunthKumar/MKNetworkKit">MKNetworkKit</a>, and Chapter 17 of <a href="http://robnapier.net/book">our book</a> is devoted to the ins-and-outs of this subject.

But sometimes you just have a simple `UIWebView`, and you want to cache the last version of the page. You'd think that `NSURLCache` would handle this for you, but it's much more complicated than that. `NSURLCache` doesn't cache everything you'd think it would. Sometimes this is because of Apple's decisions in order to save space. Just as often, however, it's because the HTTP caching rules explicitly prevent caching a particular resource.

What I wanted was a simple mechanism for the following case:

* You have a UIWebView that points to a website with embedded images
* When you're online, you want the normal caching algorithms (nothing fancy)
* When you're offline, you want to show the last version of the page

My test case was simple: a webview that loads cnn.com (a nice complicated webpage with lots of images). Run it once. Quit. Turn off the network. Run it again. CNN should display.

<a id="more"></a><a id="more-588"></a>
### Exisiting solutions

The ever-brilliant Matt Gallagher has <a href="http://cocoawithlove.com/2010/09/substituting-local-data-for-remote.html">some interesting thoughts</a> on how to subclass `NSURLCache` to handle this, but I find his solution fragile and unreliable, especially on iOS 5. The HTTP caching rules are complicated, and in many cases you need to connect to the server to re-validate your cache before you're allowed to use your local copy. Unless everything works out perfectly, his solution may not work when you're offline, or may force you to turn off cache validation (which could make your pages go stale).

<a href="https://github.com/artifacts/AFCache">AFCache</a> is also promising, using essentially the same approach. I haven't found the offline support to work very well, at least in my tests, for the same reasons as Matt's solution. It's designed to be an advanced HTTP-caching solution. The docs are limited and I couldn't get it to pass my CNN test.

### RNCachingURLProtocol

So, I present `RNCachingURLProtocol`. It isn't a replacement for `NSURLCache`. It's a simple shim for the HTTP protocol (that's not nearly as scary as it sounds). Anytime a URL is download, the response is cached to disk. Anytime a URL is requested, if we're online then things proceed normally. If we're offline, then we retrieve the cached version. The current implementation is extremely simple. In particular, it doesn't worry about cleaning up the cache. The assumption is that you're caching just a few simple things, like your "Latest News" page (which was the problem I was solving). It caches all HTTP traffic, so without some modifications, it's not appropriate for an app that has a lot of HTTP connections (see `MKNetworkKit` for that). But if you need to cache some URLs and not others, that is easy to implement.

First, a quick rundown of how to use it:

1. At some point early in the program (`application:didFinishLaunchingWithOptions:`), call the following:

      `[NSURLProtocol registerClass:[RNCachingURLProtocol class]];`

1. There is no step 2.

Since `RNCachingURLProtocol` doesn't mess with the existing caching solution, it is compatible with other caches, like `AFCache`. In fact, the technique used by `RNCachingURLProtocol` could probably be integrated into `AFCache` pretty easily.

The cache itself is stored in the `Library/Caches` directory. In iOS 5, this directory can be purged whenever space is tight. Keep that in mind. You may want to store your caches elsewhere if offline access is critical.


### Understanding NSURLProtocol

An `NSURLProtocol` is a handler for `NSURLConnection`. Each time a request is made, `NSURLConnection` walks through all the protocols and asks "Can you handle this request (`canInitWithRequest:`)?" The first protocol to return `YES` is used to handle the connection. Protocols are queried in the reverse order of their registration, so your custom handlers will get a crack at requests before the system handlers do.

Once your handler is selected, the connection will call `initWithRequest:cachedResponse:client:` and then `startLoading`. It is then your responsibility to call the connection back with `URLProtocol:didReceiveResponse:cacheStoragePolicy:`, some number of calls to `URLProtocol:didLoadData:`, and finally `URLProtocolDidFinishLoading:`. If these sound similar to the `NSURLConnection` delegate methods, that's no accident.

While online, `RNCachingURLProtocol` just forwards requests to a new `NSURLConnection`, making copies of the results, and passing them along to the original connection. When offline, `RNCachingURLProtocol` loads the previous result from disk, and plays it back to the requesting connection. The whole thing is less than 200 lines of pretty simple code (not counting `Reachability`, which I include from Apple's sample code to determine if we're online).

There's a subtle problem with the above solution. When `RNCachingURLProtocol` creates a new `NSURLConnection`, that new connection has to find a handler. If `RNCachingURLProtocol` says it can handle it, then you'll have an infinite loop. So how do I know not to handle the second request? By adding a custom header (`X-RNCache`) to the HTTP request. If it's there, then we've already seen this one, and the handler returns `NO`.

Again, this intercepts *all* HTTP traffic. That could intercept pages you don't want. If so, you can modify `canInitWithRequest:` to select just things you want to cache (for instance, you could turn off caching for URLs that include parameters or POST requests).

### Wrap-up

This technique isn't a replacement for a full caching engine like `AFCache` or an offline REST engine like `MKNetworkKit`. It's intended to solve a single, simple problem (though it can be extended to solve much more complicated problems). `NSURLProtocol` is extremely powerful, and I've used it extensively when I need to eavesdrop on network traffic (such as in PandoraBoy's several <a href="https://github.com/PandoraBoy/PandoraBoy/blob/master/ProxyURLProtocol.h">ProxyURLProtocol</a> classes). It's well-worth adding to your toolkit.

The code is in the attached project. Look in `RNCachingURLProtocol.m`.

<strong>EDIT: Be sure to see Nick Dowell's modification in the comments to handle HTTP redirect.</strong>

<strong>EDIT2: In `cachePathForRequest:`, I use `hash` to uniquely identify the URLs. For long, similar URLs, this collides a lot (See <a href="http://opensource.apple.com/source/CF/CF-476.17/CFString.c">CFString.c</a> for comments on how the hash function is implemented.) The better thing to use is MD5 or SHA1 or something, but those aren't built-in on iOS prior to iOS5, so you'd have to implement your own (and I don't need it that badly for my current projects). This is something you'd want to fix before using this seriously.</strong>

<a href='http://robnapier.net/blog/wp-content/uploads/2012/01/CachedWebView.zip'>CachedWebView Example Project</a>
