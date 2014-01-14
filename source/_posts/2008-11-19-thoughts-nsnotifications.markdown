---
layout: post
status: publish
published: true
title: Some thoughts on NSNotifications
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: "<h3>Unregistering</h3>\r\nBecause these bugs are very hard to track down
  and very easy to avoid, I'd like to direct everyone's attention to how to properly
  unregister for notifications.\r\n\r\nIf your object uses NSNotificationCenter ever,
  you must add the following to -dealloc:\r\n\r\n<pre lang=\"objc\">[[NSNotificationCenter
  defaultCenter] removeObserver:self];</pre>\r\n\r\nThis removes you from all notifications.
  If you fail to do this, and you are dealloc'ed, and a notification you were observing
  is later posted, the application will crash with a bizarre access violation deep
  in NSNotificationCenter when it tries to post to an object (you) which no longer
  exists. It is tricky to figure out even what notification is being passed in these
  cases.\r\n\r\nIf you are not observing anything, then -removeObserver: does nothing,
  so it is not dangerous to call. There is a slight performance cost, especially for
  objects that are alloc'ed and dealloc'ed a lot, so there's no reason to add it to
  objects that do nothing with notifications, but I recommend better safe than sorry
  in most cases.\r\n\r\nThis advice does not apply to KVO observations, which are
  a completely different animal. "
wordpress_id: 42
wordpress_url: http://cocoaphony.wordpress.com/?p=42
date: 2008-11-19 11:35:55.000000000 -05:00
categories:
- cocoa
tags:
- cocoa
- NSNotification
---
<h3>Unregistering</h3>
Because these bugs are very hard to track down and very easy to avoid, I'd like to direct everyone's attention to how to properly unregister for notifications.

If your object uses NSNotificationCenter ever, you must add the following to -dealloc:

<pre lang="objc">[[NSNotificationCenter defaultCenter] removeObserver:self];</pre>

This removes you from all notifications. If you fail to do this, and you are dealloc'ed, and a notification you were observing is later posted, the application will crash with a bizarre access violation deep in NSNotificationCenter when it tries to post to an object (you) which no longer exists. It is tricky to figure out even what notification is being passed in these cases.

If you are not observing anything, then -removeObserver: does nothing, so it is not dangerous to call. There is a slight performance cost, especially for objects that are alloc'ed and dealloc'ed a lot, so there's no reason to add it to objects that do nothing with notifications, but I recommend better safe than sorry in most cases.

This advice does not apply to KVO observations, which are a completely different animal. <!-- more -->

<h3>Naming</h3>
While here, it's worth noting some other significant notification advice. Never pass a hard-coded string as the name; you're begging for hard-to-track-down bugs when you mistype the string elsewhere. Create a name in the form PREFIXSomethingDidHappenNotification, for example: RNFooDidChangeNotification.

Then create a constant with this name. In .h create an extern (a promise to define it elsewhere):

<pre lang="objc">extern NSString* RNFooDidChangeNotification;</pre>

And in .m, define it (outside of your @implementation block):

<pre lang="objc">NSString* RNFooDidChangeNotification = @"RNFooDidChangeNotification";</pre>

Please make the name of the notification match its value; it will make your debugging much easier. While many constants begin with a "k", notifications do not, and delegate method naming conventions suggest they shouldn't, so please don't.

The object of a notification should generally be the object that posts the notification, and in any case should whenever possible be a "watchable" object (i.e. an object that the observer could have a pointer to). This means that the object shouldn't be created dynamically when the notification is posted (an NSNumber or NSValue for instance). Other kinds of objects should be passed in the userInfo dictionary with appropriate keys (which should also be defined as variables as above). In the above example, the observer would strongly expect the object to be of class RNFoo.

<h3>When do notification run</h3>
For those coming from Java or C++, the actual handling of notifications often is a mystery. If you're used to highly threaded environments, you're immediately wondering about timing issues like "what if I receive a notification in the middle of other processing?" In Objective-C, these issues (mostly) disappear.

-postNotification: (and the related methods) deliver notifications immediately. This is nothing like a Java JMS. -postNotification: is really just a fancy way to make a method call. As soon as you call it, the NSNotificationCenter walks through all the observers and calls all the selectors, one at a time. Only when it has finished them all does -postNotification: return. There is no extra thread. These are just method calls, and you will see them in your stack trace as though the poster called you.

A side-effect of this is that you aren't going to get random notifications in the middle of your processing. As long as you keep all your notifications on the main thread (which you should do), they will always come in synchronously.

What if you realy want to delay processing of a notification? Look at NSNotificationQueue. This will let you post notifications that get processed at the next event loop.

(Advanced issues) NSNotificationCenter responds to notifications on the thread that the notification was posted on, not the thread the notification was observed on. In multi-threaded envrionments this can be confusing. Generally the right answer is to respond to all notifications on the main thread. To achieve this, use -performSelectorOnMainThread:withObject:waitUntilDone: to call -postNotification: if the poster is on its own thread. If the observer needs to be on its own thread, it is best to let the notification come in on the main thread, and then have the observer's handler perform the -performSelector:onThread:withObject:waitUntilDone: to get the processing over to the correct thread. This way, multiple observers can have their own threads, which would not work if the poster performed the -performSelector:onThread:withObject:waitUntilDone:.
