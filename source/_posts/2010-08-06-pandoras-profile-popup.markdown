---
layout: post
status: publish
published: true
title: Pandora's "Profile" pop-up
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: "Several people have noted that PandoraBoy is displaying a \"Profile\" window
  over the player that interferes with the player. This is a notification from Pandora
  because they've changed their privacy settings (you can now make your profile private,
  and they want to know if you want that).\r\n\r\nThis should be a one-time event
  for existing accounts. I suspect that new accounts will not see it. The solution
  is to open www.pandora.com in Safari, answer the question, and then re-launch PB."
wordpress_id: 529
wordpress_url: http://robnapier.net/blog/?p=529
date: 2010-08-06 10:14:58.000000000 -04:00
categories:
- PandoraBoy
tags: []
---
Several people have noted that PandoraBoy is displaying a "Profile" window over the player that interferes with the player. This is a notification from Pandora because they've changed their privacy settings (you can now make your profile private, and they want to know if you want that).

This should be a one-time event for existing accounts. I suspect that new accounts will not see it. The solution is to open www.pandora.com in Safari, answer the question, and then re-launch PB.

PandoraBoy goes directly to the the mini-player on launch. Pandora doesn't code for that since it's impossible from the website. So sometimes they make interfaces that are larger than the mini-player without updating the mini-player code to resize. PB doesn't resize the window (it doesn't know how large it should be). It just relies on the mini-player to do it in Javascript, but in cases like this, the mini-player also doesn't know how large the window should be.

BTW, I often am asked why PB doesn't make the window resizable for cases like this. The answer is that it doesn't help. The mini-player is a flash app, and has a clipping frame independent of the window. So while you can resize the window, the content is still clipped at the border of the flash app. Ah, the wonders of Flash.
