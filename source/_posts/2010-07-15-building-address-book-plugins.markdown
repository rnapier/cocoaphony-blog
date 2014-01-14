---
layout: post
status: publish
published: true
title: Building Address Book plugins
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
wordpress_id: 520
wordpress_url: http://robnapier.net/blog/?p=520
date: 2010-07-15 16:17:22.000000000 -04:00
categories:
- cocoa
tags: []
---
Just a reminder, because the template doesn't seem to set this up correctly. To build an Address Book action plugin for 10.6, you need to compile for x86_64 or it will silently not show up. If you plan to support 10.5, you'll need i386 as well. The template seems to build 32-bit universal (i386, ppc) by default.
