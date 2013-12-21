---
layout: post
status: publish
published: true
title: PandoraBoy 0.8.2 - Fixes Flash
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: "For those of you having trouble with Flash 10.1, I've fixed PB to handle
  it. This moves from the hackish \"dig around in the NetscapePlugin objects and call
  undocumented methods\" approach to a standard CGEvent based keyboard injection.
  You can't use NSApp's sendEvent: to talk to Flash (probably because Flash is not
  in Cocoa). But the following code is a good general purpose \"send me a virtual
  keystroke.\"\r\n"
wordpress_id: 523
wordpress_url: http://robnapier.net/blog/?p=523
date: 2010-07-15 23:30:24.000000000 -04:00
categories:
- cocoa
- PandoraBoy
tags: []
---
For those of you having trouble with Flash 10.1, I've fixed PB to handle it. This moves from the hackish "dig around in the NetscapePlugin objects and call undocumented methods" approach to a standard CGEvent based keyboard injection. You can't use NSApp's sendEvent: to talk to Flash (probably because Flash is not in Cocoa). But the following code is a good general purpose "send me a virtual keystroke."
<a id="more"></a><a id="more-523"></a>

    - (void)sendKeyPress:(int)keycode withModifier:(int)modifier
    {
    	ProcessSerialNumber psn;
    	GetCurrentProcess(&psn);
    	CGEventRef modifierEvent;
    	if (modifier != 0)
    	{
    		modifierEvent = CGEventCreateKeyboardEvent(NULL, modifier, YES);
    		CGEventPostToPSN(&psn, modifierEvent);
    	}
    	
    	CGEventRef keyEvent = CGEventCreateKeyboardEvent(NULL, keycode, YES);
    	CGEventPostToPSN(&psn, keyEvent);
    	CGEventSetType(keyEvent, kCGEventKeyUp);
    	CGEventPostToPSN(&psn, keyEvent);
    	CFRelease(keyEvent);
    		
    	if (modifier != 0)
    	{
    		CGEventSetType(modifierEvent, kCGEventKeyUp);
    		CGEventPostToPSN(&psn, modifierEvent);
    		CFRelease(modifierEvent);
    	}
    }

First note the use of `CGEventPostToPSN()`. I originally made the mistake of using `CGEventPost()`. The problem is that this will send the keystroke to the currently active application, not PandoraBoy. For keyboard shortcuts and applescript where PB will certainly be in the background, `CGEventPostToPSN()` is a must here.

Note that this uses virtual keycodes. That's fine for PB, since (for now) we only send things that are universal (like spacebar). But it will be a problem when I implement sending "z" to snooze a song. The problem is that "z" means "the location of 'z' on an ANSI keyboard." If you have a different keyboard layout, it's still going to act like you pressed that lower left-hand key beside the shift, not "z". If people have trouble with this, I'll look into UCKeyboardLayout, but it was too much for tonight, and I don't need it myself.

The modifiers are tricky because if you want to send "Z" that really means "shift down, z down, z up, shift up." This method takes care of all that for you. You would send "Z" like this:

    [self sendKeyPress:kVK_ANSI_Z withModifier:kVK_Shift];
