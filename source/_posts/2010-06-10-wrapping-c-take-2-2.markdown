---
layout: post
status: publish
published: true
title: Wrapping C++ - Take 2, Part 2
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: In the <a href="http://robnapier.net/blog/wrapping-c-take-2-1-486">last post</a>,
  we discussed how to wrap simple C++ objects in Objective-C. But how about more complex
  objects, particularly with `shared_ptr`?
wordpress_id: 493
wordpress_url: http://robnapier.net/blog/?p=493
date: 2010-06-10 01:48:41.000000000 -04:00
categories:
- cocoa
- iphone
tags: []
---
In the <a href="http://robnapier.net/blog/wrapping-c-take-2-1-486">last post</a>, we discussed how to wrap simple C++ objects in Objective-C. But how about more complex objects, particularly with `shared_ptr`?<a id="more"></a><a id="more-493"></a> 

Many of the objects I deal with include these, and there are a few special concerns:

* You can't take a `shared_ptr` to an object during its constructor.
* You can't easily store a `shared_ptr` directly in an ivar using the opaque object previously discussed (it relies on a raw pointer to a struct).

Consider the following object (slightly abbreviated; a `WrapPtr` is a `shared_ptr<Wrap>`):

	class WrapListener {
	public:
		virtual void onStringDidChange(WrapPtr wrap) = 0;
	};

	class Wrap : public enable_shared_from_this<Wrap> {
	public:
		Wrap(string str) : m_string(str), m_listeners() {};
		string getString() { return m_string; };
		void setString(string str);
		void addListener(WrapListenerPtr listener) { m_listeners.insert(listener); };
		void removeListener(WrapListenerPtr listener) { m_listeners.erase(listener); };
	private:
		string m_string;
		WrapListenerWeakSet m_listeners;
	};

This is a very common pattern in the code I work with, but it has a problem for wrapping. If we make the opaque object the listener, there's no easy way to call `addListener()` during the constructor. For example we might be tempted to do this:

	struct RNWrapOpaque : public RN::WrapListener,
		public enable_shared_from_this<RNWrapOpaque> {
	public:
		RNWrapOpaque(RNWrap *owner, string aStr) : 
		m_owner(owner), wrap(new RN::Wrap(aStr)) {
			wrap->addListener(shared_from_this());
		};
	
		~RNWrapOpaque() {
			wrap->removeListener(shared_from_this());
		}
	
		void onStringDidChange(RN::WrapPtr cppWrap) {
			[m_owner.delegate wrapStringDidChange:m_owner];
		}		
	
		RN::WrapPtr wrap;
	private:
		RNWrap *m_owner;
	};

Unfortunately, this will crash. It's not possible to call `shared_from_this()` during a constructor. This can often be solved by adding a `Create()` method to separate construction from initialization. That's a good pattern, but doesn't work here because there's nowhere to store the `shared_ptr`. We have to store a raw pointer in the header.

The best solution I believe is to accept that you need a second object for the listener. This actually scales pretty well since the opaque struct may store several objects, and breaking up the different listeners can be better for readability. So that brings us to our example:

	class MyWrapListener : public RN::WrapListener {
	public:
		MyWrapListener(RNWrap *owner) : m_owner(owner) {};

		void onStringDidChange(RN::WrapPtr cppWrap) {
			[m_owner.delegate wrapStringDidChange:m_owner];
		}	

	private:
		RNWrap *m_owner;	
	};

	struct RNWrapOpaque {
	public:
		RNWrapOpaque(RNWrap *owner, string aStr) : 
		wrap(new RN::Wrap(aStr)),
		m_wrapListener(new MyWrapListener(owner)) {
			wrap->addListener(m_wrapListener);
		};
	
		~RNWrapOpaque() {
			wrap->removeListener(m_wrapListener);
		}
	
		RN::WrapPtr wrap;
	private:
		RN::WrapListenerPtr m_wrapListener;
	};

	@implementation RNWrap

	- (id)initWithString:(NSString *)aString delegate:(id<RNWrapDelegate>)aDelegate {
		self = [super init];
		if (self != nil) {
			self.cpp = new RNWrapOpaque(self, [aString UTF8String]);
			self.delegate = aDelegate;
		}
		return self;
	}

The rest is generally as in the previous article.

<a href='http://robnapier.net/blog/wp-content/uploads/2010/06/CppWrap.zip'>CppWrap.zip</a>
