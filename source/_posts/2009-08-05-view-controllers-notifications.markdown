---
layout: post
status: publish
published: true
title: View controllers and notifications
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: Observing NSNotifications in a view control is a good thing. But remember,
  just because you're not onscreen doesn't mean that you're not still observing. ...
  Be on the lookout for Controllers who are doing Model work. A View can get data
  through its ViewController, and other controllers can access view information from
  the ViewController. But if model objects are talking to a ViewController, it's probably
  become too big.
wordpress_id: 160
wordpress_url: http://robnapier.net/blog/?p=160
date: 2009-08-05 14:33:56.000000000 -04:00
categories:
- cocoa
tags: []
---
Observing NSNotifications in a view control is a good thing. But remember, just because you're not onscreen doesn't mean that you're not still observing. This is particularly noteworthy on iPhone, where your view can get dropped any time memory is tight and you're offscreen, but it can bite you anywhere.

ViewControllers, WindowControllers and other UI controllers are often better off registering and uregistering for notifications when they are put on and off the screen rather than when they are allocated and deallocated. This often means that they will need to update their state when put on screen. For example, an icon indicating "connected" might be part of a StatusViewController. When StatusView comes on screen, StatusViewController should update the connected status and then begin observing changes on it. When StatusView goes off screen, StatusViewController should stop observing.
<a id="more"></a><a id="more-160"></a>
But wait, what if StatusViewController is the only thing keeping track of of the connection status? Then when StatusView comes on screen, there's no one to ask for the current status. This tells us that StatusViewController is doing too much. It's gone beyond being a Controller and has started holding data, which makes it a Model class. The fix? A model object should be keeping track of current connection status. A Connection object, a Status object or whatever makes sense. But not the ViewController. The ViewController's job is to manage the view (the drawing of data), not store data. Since Status never goes on or off the screen, it will always be able to observe the current connection state and will always be available for the ViewController to query.

Be on the lookout for Controllers who are doing Model work. A View can get data through its ViewController, and other controllers can access view information from the ViewController. But if model objects are talking to a ViewController, it's probably become too big.

Simple rule: don't store data in anything that imports UIKit.h or Cocoa.h. If you can't get by with Foundation.h, you're not a model object.
