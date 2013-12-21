---
layout: post
status: publish
published: true
title: Wrapping C++ Final Edition
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: Wrapping C++ for use by ObjC used to be somewhat complicated, especially
  if the C++ include namespaces or templates. Changes in ObjC have now made it nearly
  trivial. In my (hopefully) final installment on the subject, I lay out just how
  easy it is now.
wordpress_id: 759
wordpress_url: http://robnapier.net/blog/?p=759
date: 2012-05-12 20:11:45.000000000 -04:00
categories:
- cocoa
tags: []
---
I have always strong recommended segregating Objective-C and C++ code with a thin Objective-C++ wrapper. I do not like Objective-C++. It is useful for what it does, but it is a mess of a "language." It has many downsides, for slower compiles and poor debugging facilities, to confusing code and inefficient ARC code. `.mm` is a blight on your code. Never let it spread.

That said, Objective-C++ is invaluable for integrating C++ into Objective-C. And while I am not a great lover of C++, it is a very useful language and there is a great deal of excellent code written in it that is well-worth reusing in your Cocoa projects. Many of Apple's frameworks are implemented in C++.

So my recommendation for those who have existing C++ logic code has always been thus: write your UI in pure Objective-C (.m). Write your "middleware" in pure C++ (.cpp). And have a thin Objective-C++ (.mm) wrapper layer to glue them together. Your ObjC++ API should ideally exactly match your C++ API, just converting types (for instance converting std::string to and from NSString).

(As a side note, I also recommend that OS-related things like file management, network management, and threading all be handled natively. GCD is much better than pthreads. NSURLConnection is much better than writing your own C++ networking layer in BSD sockets. But this is tangental to the main point.)

Saying all that, how do you wrap a C++ object so that Objective-C can read it? This used to be a question that required some significant thought. See <a href="http://robnapier.net/blog/wrapping-c-take-2-1-486">Wrapping C++, Take 2 Part 1</a> and <a href="http://robnapier.net/blog/wrapping-c-take-2-2-493">Part 2</a> for my previous thinking on the subject.

Improvements in Objective-C have made all of the previous hoop-jumping irrelevant. The problem all my previous solutions was trying to solve was that you had to declare ivars in the header. Your ivar was a C++ class (which might be in a namespace or might be a template), and that made it difficult to declare in the header without forcing all the importers to be ObjC++. So to solve this generally you needed opaque types, or at the very least forward declared structs, etc. And it was all a big pain.

But that's over. You can now declare all your ivars in the implementation file. So everything's easy. Your wrapper class can have C++ ivars without having any impact on users of the wrapper class.

Consider a simple C++ class (but throwing in the headache of a namespace):

    namespace MY {
    class Cpp {
      public:
        std::string getName() { return _name; };
        void setName(std::string aName) { _name = aName; };
      private:
        std::string _name;
    };
    }

The wrapper for this is trivial:

    @interface CPPWrapper : NSObject
    @property (nonatomic, readwrite, copy) NSString *name;
    @end

    @interface CPPWrapper ()
    @property (nonatomic, readwrite, assign) MY::Cpp *cpp;
    @end

    @implementation CPPWrapper
    @synthesize cpp = _cpp;

    - (id)init {
      self = [super init];
      if (self) {
        _cpp = new MY::Cpp();
      }
      return self;
    }

    - (void)dealloc {
      delete _cpp;
    }

    - (NSString *)name {
      return [NSString stringWithUTF8String:self.cpp->getName().c_str()];
    }

    - (void)setName:(NSString *)aName {
      self.cpp->setName([aName UTF8String]);
    }
    @end

Couldn't be easier really. The one headache that really remains in my experience is enums inside of a namespace (or more generally enums declared in a C++ header). The best solution is to use `#if __cplusplus` blocks to strip away the namespace and still declare the enum in pure C. Do this if at all possible. Otherwise you'll wind up with an C enum that mirrors the C++ enum. This is a maintenance nightmare, since changes to the C++ enum will often be missed in the ObjC enum, and you'll get very difficult-to-debug errors with enum mismatches.

Just to ask and answer a possible question: why `*Cpp` and not just `Cpp`? The reason is that in almost all cases the C++ object will be created outside of your wrappers. So in almost all cases, there's going to be a method like `initWithCpp:(Cpp *)cpp`. How does that work? Easy, wrap it in `#if __cplusplus`:

    #if __cplusplus
    #include "Cpp.h"
    ...
    - (CppWrapper *)initWithCpp:(Cpp *)cpp;
    #endif

Anyway, most of my research into opaque types and generally how to manage C++ wrappers has now become trivial. I'm just giving one more post to let you all know that. (And because <a href="http://robnapier.net/blog/wrapping-c-take-2-1-486#comment-15967">Orpheus</a> asked.) Post comments if there are more questions.
