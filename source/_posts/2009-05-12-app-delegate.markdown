---
layout: post
status: publish
published: true
title: App Delegate
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: Answering a on Stack Overflow, asking for an explanation of the Application
  Delegate (UIApplicationDelegate or NSApplicationDelegate), how it is accessed and
  created.
wordpress_id: 343
wordpress_url: http://robnapier.net/blog/?p=343
date: 2009-05-12 08:00:16.000000000 -04:00
categories:
- cocoa
tags:
- cocoa
- cocoa touch
---
<em>Answering a <a href="http://stackoverflow.com/questions/828827/what-describes-the-application-delegate-best-how-does-it-fit-into-the-whole-conc/829591#829591">question</a> on Stack Overflow, asking for an explanation of the Application Delegate, how it is accessed and created.</em>

In Cocoa, a delegate is an object that another object defers to on questions of behavior and informs about changes in its state. For instance, a UITableViewDelegate is responsible for answering questions about how the UITableView should behave when selections are made or rows are reordered. It is the object that the UITableView asks when it wants to know how high a particular row should be. In the Model-View-Controller paradigm, delegates are Controllers, and many delegates' names end in "Controller."
<a id="more"></a><a id="more-343"></a>
At risk of stating the obvious, the UIApplicationDelegate is the delegate for the UIApplication. The relationship is a bit more obvious in Cocoa (Mac) than in Cocoa Touch (iPhone), since the NSApplication delegate is able to control the NSApplication's behavior more directly (preventing the application from terminating for instance). iPhone doesn't permit much control over the UIApplication, so mostly the UIApplicationDelegate is informed of changes rather than having an active decision-making process.

The UIApplicationDelegate isn't strictly available from everywhere in the app. The singleton UIApplication is (UIApplication -sharedApplication), and through it you can find its delegate. But this does not mean that it's appropriate for every object in an app to talk directly to the app delegate. In general, I discourage developers from having random objects talk to the app delegate. Most problems that are solved that way are better solved through Singletons, NSNotification, or other delegate objects.

As to its creation, on Mac there is nothing magical about the app delegate. It's just an object instantiated and wired by the NIB in most cases. On iPhone, however, the app delegate can be slightly magical if instantiated by UIApplicationMain(). The fourth parameter is an NSString indicating the app delegate's class, and UIApplicationMain() will create one and set it as the delegate of the sharedApplication. This allows you to set the delegate without a NIB (something very difficult on Mac). If the fourth parameter to UIApplicationMain() is nil (as it is in the Apple templates), then the delegate is created and wired by the main NIB, just like the main window.
