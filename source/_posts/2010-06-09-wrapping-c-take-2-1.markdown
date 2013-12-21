---
layout: post
status: publish
published: true
title: Wrapping C++ - Take 2, Part 1
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: You have a C++ object that you want to consume in Objective-C. That's easy
  in ObjC++, but if you make an ivar that references a C++ class, then the header
  file can only be included by ObjC++ classes. This quickly spreads .mm files throughout
  your project, creating all kinds of headaches. ObjC is a beautiful thing, and C++
  is fine, but ObjC++ is a crazy land that should be carefully segregated from civilized
  code. So how do we do it?
wordpress_id: 486
wordpress_url: http://robnapier.net/blog/?p=486
date: 2010-06-09 02:39:04.000000000 -04:00
categories:
- cocoa
- iphone
tags:
- cocoa
- c++
- objective-c
---
Last year, I presented <a href="http://robnapier.net/blog/wrapping-c-objc-20">an approach to wrapping C++</a>. Since then, I've been introduced to other approaches, particularly from gf who helped me better understand opaque objects. Since I do a lot of cross-language work, I've had some opportunity to play with and expand this, and so I'd like to update my C++ wrapping approach.

First, to remind everyone of the problem: you have a C++ object that you want to consume in Objective-C. That's easy in ObjC++, but if you make an ivar that references a C++ class, then the header file can only be included by ObjC++ classes. This quickly spreads .mm files throughout your project, creating all kinds of headaches. ObjC is a beautiful thing, and C++ is fine, but ObjC++ is a crazy land that should be carefully segregated from civilized code. So how do we do it?

<!-- more -->
We create a thin wrapper object to provide an ObjC face on a C++ object. The challenge is how to hide C++ classes from the header file. The answer is to put them in a struct that you forward declare so you don't have to expose its contents. Structs are almost identical with C++ classes, but their forward declaration syntax is C-compatible (unlike class). Let's look at how this is done.

For this example, we will consider a C++ class called `RN::Wrap`. It holds a simple string with set and get accessors.

	class Wrap {
	public:
		Wrap(string str) : m_string(str) {};
		string getString() { return m_string; };
		void setString(string str) { m_string = str; };
	private:
		string m_string;
	};

We wrap this into Objective-C++ using an opaque structure, `RNWrapOpaque`:

    struct RNWrapOpaque;
    @interface RNWrap : NSObject {
	    struct RNWrapOpaque *_cpp;
    }

Since we only include a raw pointer to `RNWrapOpaque`, we don't have to declare anything else about it in the header file. If we tried to store the actual struct here (rather than a pointer), then that would defeat the purpose. This is the only raw pointer we will need.

Since structs are almost identical to classes in C++, we can use class features like constructors and destructors in the implementation (.mm file):

    struct RNWrapOpaque {
    public:
	    RNWrapOpaque(string aStr) : wrap(aStr) {};
    	RN::Wrap wrap;
    };

Now initializing and using the opaque object is easy in ObjC++ code:

    - (id)initWithString:(NSString *)aString {
	    self = [super init];
	    if (self != nil) {
		    self.cpp = new RNWrapOpaque([aString UTF8String]);
	    }
	    return self;
    }

    - (void)dealloc {
	    delete _cpp;
	    _cpp = NULL;	
	    [super dealloc];
    }

    - (void)setString:(NSString *)aString {
	    self.cpp->wrap.setString([aString UTF8String]);
    }
	
    - (NSString *)string {
	    return [NSString stringWithUTF8String:
			self.cpp->wrap.getString().c_str()];
    }

A nice side effect of this usages is that C++ objects are easy to detect through the `self.cpp` prefix. Memory management is easy since there is only one raw C++ pointer.

Using the class requires no special work. It's pure ObjC:

	RNWrap *wrap = [[[RNWrap alloc] initWithString:@"my string"] autorelease];
	NSLog(@"wrap = %@", [wrap string]);

In <a href="http://robnapier.net/blog/wrapping-c-take-2-2-493">part two</a>, we'll discuss how to extend this approach to more complex problems such as smart pointers, listeners/delegates, and bindings.

<a href='http://robnapier.net/blog/wp-content/uploads/2010/06/SimpleCppWrap.zip'>SimpleCppWrap.zip</a>
