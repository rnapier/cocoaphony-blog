---
layout: post
status: publish
published: true
title: Wrapping C++ in ObjC
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: "<em>See <a href=\"http://robnapier.net/blog/wrapping-c-take-2-1-486\">Take
  2</a> for an updated approach to this problem.</em>\r\n\r\nWhen faced with mixing
  C++ and ObjC code, there are two main approaches. One is to just work in Objective-C++
  through the entire project. I don't like this approach. I find the mixing of ObjC
  and C++ classes very confusing, since they cannot be used interchangeably and require
  completely different memory management. The mix of class hierarchies and naming
  conventions lead to a lot of confusion when we introduce people to code that does
  this kind of mixing.\r\n\r\nMy opinion is that ObjC and C++ have very different
  patterns, so it is important to pick one to be in charge and wrap the other. So
  if you basically have an C++ program than needs a little ObjC to talk to the UI,
  then wrap the ObjC in C++ objects. If you basically have an ObjC program that needs
  a C++ middleware, then wrap the C++ objects."
wordpress_id: 20
wordpress_url: http://cocoaphony.wordpress.com/?p=20
date: 2009-04-14 10:20:03.000000000 -04:00
categories:
- cocoa
tags:
- cocoa
- c++
- objective-c
---
<em>See <a href="http://robnapier.net/blog/wrapping-c-take-2-1-486">Take 2</a> for an updated approach to this problem.</em>

When faced with mixing C++ and ObjC code, there are two main approaches. One is to just work in Objective-C++ through the entire project. I don't like this approach. I find the mixing of ObjC and C++ classes very confusing, since they cannot be used interchangeably and require completely different memory management. The mix of class hierarchies and naming conventions lead to a lot of confusion when we introduce people to code that does this kind of mixing.

My opinion is that ObjC and C++ have very different patterns, so it is important to pick one to be in charge and wrap the other. So if you basically have an C++ program than needs a little ObjC to talk to the UI, then wrap the ObjC in C++ objects. If you basically have an ObjC program that needs a C++ middleware, then wrap the C++ objects.<!-- more -->

Here's how I usually wrap a C++ object (CFoo) into a ObjC object (Foo):
<h4>Foo.h</h4>
<pre lang="objc">
typedef void* CFooRef;
@interface Foo : NSObject {
   CFooRef _fooRef;
}
</pre>
<h4>Foo+CPP.h</h4>
<pre lang="objc">
#import "Foo.h"
@interface Foo (CPP)
@property (readwrite, assign) CFoo* foo;
@end
</pre>
<h4>Foo.mm</h4>
<pre lang="objc">
#import "Foo+CPP.h"
@interface Foo () {
@property (readwrite, assign) CFooRef fooRef;
@end

class CFoo { ... }; // Define the C++ object here, or in a separate file.

@implementation Foo
@synthesize fooRef=_fooRef;

- (CFoo*)foo {
   return static_cast<cfoo*>([self fooRef]);
}

- (void)setFoo:(CFoo*)aFoo {
   [self setFooRef:aFoo];
}
@end
</pre>

The goal of this is to provide a pure-ObjC interface (Foo.h) that has no C++ in it. The CFooRef type allows ObjC to treat the C++ object as an opaque type. Other C++ wrapper objects can access the underlying C++ object using the Foo+CPP.h interface, but I only provide this if there are other objects that really need it.

In general, I then provide ObjC methods to all the relevant C++ methods. This way, higher level classes (generally UI classes) can be pure ObjC. This makes it much easier to tie these C++ objects into Cocoa. I can use the wrapper to make the C++ bindings compliant, put them into NSArrays, etc. And when we hire ObjC developers, they can focus on ObjC without learning the intricacies of C++. Similarly, the C++ stays pure C++, making it much easier for C++ developers to work on, and keeps it portable. Only the guys who work on the wrappers (guys like me) have to really keep their head in both languages and both sets of patterns. And we keep the wrappers as thin as possible to minimize the work done there. Ideally, the wrappers can do simple language translation and nothing else.

After years of evolving this approach in multiple projects, this has been the most successful for our large mixed-language projects.

<strong>EDIT:</strong> After doing this for a long time, I've learned that using "#ifdef __cplusplus" in your header file around the C++ code can be much easier than maintaining a separate "+CPP" header.
