---
layout: post
status: publish
published: true
title: Private Frameworks' install path
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
wordpress_id: 94
wordpress_url: http://robnapier.net/blog/?p=94
date: 2008-03-05 10:03:30.000000000 -05:00
categories:
- cocoa
- PandoraBoy
tags:
- cocoa
- PandoraBoy
- Frameworks
---
To all you aspiring Cocoa developers....

If you want to make a private framework, you need to remember to set the install path for it to <span>@executable_path/../Frameworks</span>. Just copying it into your bundle isn't good enough. Otherwise your app is going to think it's in (~)/Library/Frameworks once you package it up and give it to other people.

In related news, PandoraBoy 0.5.1<span>a</span> is now released.
