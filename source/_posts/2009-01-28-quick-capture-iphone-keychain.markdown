---
layout: post
status: publish
published: true
title: Quick capture about iPhone Keychain
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
wordpress_id: 62
wordpress_url: http://robnapier.net/blog/?p=62
date: 2009-01-28 18:48:18.000000000 -05:00
categories:
- iphone
tags:
- iphone
- keychain
---
<ul>
	<li>There is only one keychain, and it belongs to the OS.
<ul>
	<li>It is backed-up, but it's encrypted w/ a key that is not backed-up.</li>
</ul>
</li>
	<li>You can only read your own keychain entries, so you can't share data this way</li>
	<li>"Your own" is defined by your application name (not identifier)
<ul>
	<li>If you change your application name to match some other application, you can read it's keychain</li>
	<li>You will of course overwrite that application in the process</li>
	<li>This fact does not appear to be documented, so it might change</li>
</ul>
</li>
	<li>Because the keychain belongs to the OS, it outlives your app.
<ul>
	<li>Even if your app is deleted from the phone</li>
	<li>And reinstalled... your old keychain data is still there.</li>
	<li>Beware if you change your keychain format</li>
	<li>I know of no way to clear out the old data except to walk through and delete them all inside your app</li>
</ul>
</li>
</ul>
