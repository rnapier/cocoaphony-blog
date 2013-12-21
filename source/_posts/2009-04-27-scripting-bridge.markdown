---
layout: post
status: publish
published: true
title: Scripting Bridge
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: Apple has created an incredible new framework with Scripting Bridge, making
  it easier than ever to tie your application into the system and interact with other
  programs. Unfortunately, they buried much of the documentation, and left much to
  the imagination of the reader (like most Applescript documentation). Hopefully this
  article can help improve that situation and make Applescript a bigger part of your
  programs.
wordpress_id: 265
wordpress_url: http://robnapier.net/blog/?p=265
date: 2009-04-27 22:13:27.000000000 -04:00
categories:
- cocoa
tags:
- cocoa
- applescript
- Scripting Bridge
---
Say you want to talk to another app through Applescript. With 10.5, you can much more easily get there from Cocoa without complex forays into CoreServices, Carbon and AppleEvents. The docs on how to do it are a little thin at times (as all Applescript docs are), so let's walk through it. The relevant docs you'll want to read are these:

<a href="http://www.apple.com/applescript/learn.html">Learning Applescript</a>

<a href="http://developer.apple.com/documentation/ScriptingAutomation/Reference/ScriptingBridgeFramework">Scripting Bridge Framework Reference</a>

<a href="http://developer.apple.com/samplecode/SBSystemPrefs/index.html">Scripting Bridge Sample Code</a>

And most importantly (and most hidden):

<a href="https://developer.apple.com/library/mac/#samplecode/SBSystemPrefs/Listings/ReadMe_txt.html">SBSystemPref's Magical README</a>

And now for a step-by-step example. We're going to send some mail with an attachment through Mail.app.
<!-- more -->
I'm going to assume you know enough Applescript to have written this:

<pre lang="applescript">
tell application "Mail"
    set theMessage to make new outgoing message with properties ¬
        {subject:"Test outgoing", content:"Test body"}
    tell theMessage
        make new to recipient at end of to recipients with properties ¬
            {name:"Rob Napier", address:"sb@robnapier.net"}
        tell content
            make new attachment with properties {filename:"/etc/hosts"} ¬
                at after last paragraph
            set visible of theMessage to true
        end tell
    end tell
    activate
end tell
</pre>

Let's convert it to Scripting Bridge.

<h3>Setting up your project</h3>

<ol>
<li>Add ScriptingBridge.Framework to your project:
    <ul>
    <li>Open Targets</li>
    <li>Double-click the Target</li>
    <li>Select the General Tab</li>
    <li>Click "+" for Linked Libraries</li>
    <li>Add ScriptingBridge.framework</li>
    </ul></li>

<li>Add a rule for creating .h files for scriptable Applications (this should be built into XCode, but isn't). You could also do this by hand one time, and just add the resulting .h to your project.
    <ul>
    <li>Select the Rules tab</li>
    <li>Click "+"</li>
    <li>Process: Source files with name matching: *.app</li>
    <li>Using: Custom Script: (the following needs to be one long line)
    <pre lang="bash">sdef "$INPUT_FILE_PATH" | sdp -fh -o "$DERIVED_FILES_DIR" --basename
"$INPUT_FILE_BASE" --bundleid `defaults read "$INPUT_FILE_PATH/Contents/Info"
CFBundleIdentifier`</pre></li>
    <li>Click the "+" under "with output files:"
        <pre lang="objc">$(DERIVED_FILES_DIR)/$(INPUT_FILE_BASE).h</pre></li>
    <li>Close the Target window. We're done with the really crazy part.</li>
    </ul></li>

<li>Add the application as one of your sources.
    <ul>
    <li>Drag the desired application (Mail.app) into your Groups & Files tree. You can put it in a group if you like</li>
    <li>Unselect "Copy items into destination group's folder" (if it is selected)</li>
    <li>Drag the application into your "Compile Sources" step in your Target (it should be first, so the .h gets created before it's needed). Yes, we are "compiling" an application into a header.</li>    
    </ul></li>

<li>Include the new header file in your program
    <ul>
    <li>In your .m file:
        <pre lang="objc">
#import <ScriptingBridge/SBApplication.h>
#import "Mail.h"</pre></li>
    </ul></li>

<li>Build
    <ul>
    <li>Now is a good time to build. That will get your .h created, making everything easier later. It's created in your <code>DerivedSources</code> directory. The easiest way to open it is with Cmd-Shift-D (Open Quickly). Just hit Cmd-Shift-D, and then type "mail.h".  Once you've found it, you can drag it into your Groups & Files list if you like. It will be deleted when you Build Clean, so don't be surprised by that. Aren't you glad you learned about Open Quickly? It's my favorite way to move between files.</li>
    </ul></li>
</ol>

<h3>Writing the code</h3>
OK, we now have everything in place to write some code. The process of converting from Applescript to SB is fairly mechanical, but like all Applescript things there are some things you just need to know. We're going to take this one line at a time.

<pre lang="applescript">
tell application "Mail"
</pre>

We need an SBApplication object to <code>tell</code> things to. So we make one:

<pre lang="objc">
MailApplication *mail = 
    [SBApplication applicationWithBundleIdentifier:@"com.apple.mail"];
</pre>

Notice that you can't call <code>[[MailApplication alloc] init]</code>. This is more a limitation of the sdp tool we used to create the .h than of ScriptingBridge. There is no Mail.m file to actually implement the MailApplication class, so you can't directly allocate the class. You'll see more of this limitation later.

<pre lang="applescript">
set theMessage to make new outgoing message with properties ¬
    {subject:"Test outgoing", content:"Test body"}
</pre>

We're creating a new outgoing message. This includes a special step that you can partially guess, and somewhat just have to know. Every scripting object you talk to has to chain back to the SBApplication. You can't deal with stand-alone SBObjects. In this case, the Applescript has an implicit step that we need to make explicit. The Applescript above is implicitly adding <code>theMessage</code> to <code>outgoing messages</code>. When you get used to it, it's kind of obvious, and if you look in Mail.app, you'll see that MailApplication has an <code>-outgoingMessages</code> property. But it can be a little surprising when you're getting stared. So let's rewrite the Applescript to be more explicit:

<pre lang="applescript">
set theMessage to make new outgoing message at end of outgoing messages ¬
    with properties {subject:"Test outgoing", content:"Test body"}
</pre>

And so here's the code:

<pre lang="objc">
MailOutgoingMessage *mailMessage =
    [[[[mail classForScriptingClass:@"outgoing message"] alloc]
        initWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
            @"Test outgoing", @"subject",
            @"Test body\n\n", @"content",
            nil]] autorelease];
[[mail outgoingMessages] addObject:mailMessage];
</pre>

This is a very common pattern, so it's worth studying. First, note that we can't directly <code>+alloc</code> the MailOutgoingMessage. We have to ask for it through the SBApplication object. This is more of the limitation discussed above. And we need to pass the Applescript class "outgoing message." This is obvious from the MailOutgoingMessage name once you see how <code>sdp</code> creates the .h file. The properties we pass SB are identical to the ones we pass Applescript. And once we create it, we add it into the object tree with <code>-addObject:</code>, which adds "at end of" the list just like we need (just like an NSArray). OK, now go back and read this paragraph again and make sure you've got it. We're going to use this several times.

<pre lang="applescript">
tell theMessage
    make new to recipient at end of to recipients with properties ¬
        {name:"Rob Napier", address:"sb@robnapier.net"}
</pre>

You should be able to guess the code for this one:

<pre lang="objc">
MailToRecipient *recipient = [[[[mail classForScriptingClass:@"to recipient"] alloc] 
    initWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
                    @"Rob Napier", @"name",
                    @"sb@robnapier.net", @"address",
                    nil]] autorelease];
[[mailMessage toRecipients] addObject:recipient];
</pre>

And once more for fun:

<pre lang="applescript">
tell content
    make new attachment with properties {filename:"/etc/hosts"} ¬
        at after last paragraph
</pre>
==>
<pre lang="objc">
MailAttachment *attachment = [[[[mail classForScriptingClass:@"attachment"] alloc]
    initWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
        @"/etc/hosts", @"filename",
        nil]] autorelease];
[[[mailMessage content] paragraphs] addObject:attachment];
</pre>

Those really are the complicated ones (and they aren't bad at all once you see how to read them). After that, everything should be obvious:

<pre lang="applescript">
        set visible of theMessage to true
    end tell
end tell
activate
</pre>

Becomes:

<pre lang="objc">
[mailMessage setVisible:YES];
[mail activate];
</pre>

<h3>The Finished Code</h3>
So let's look at the full code now, including a @try/@catch, since Applescript can generate exceptions (more about this below):

<pre lang="objc">
@try
{
    MailApplication *mail = 
        [SBApplication applicationWithBundleIdentifier:@"com.apple.mail"];
    MailOutgoingMessage *mailMessage =
        [[[[mail classForScriptingClass:@"outgoing message"] alloc]
            initWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
                    @"Test outgoing", @"subject",
                    @"Test body\n\n", @"content",
                    nil]] autorelease];
    [[mail outgoingMessages] addObject:mailMessage];

    MailToRecipient *recipient =
        [[[[mail classForScriptingClass:@"to recipient"] alloc]
            initWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
                    @"Rob Napier", @"name",
                    @"sb@robnapier.net", @"address",
                    nil]] autorelease];
    [[mailMessage toRecipients] addObject:recipient];

    MailAttachment *attachment =
        [[[[mail classForScriptingClass:@"attachment"] alloc]
            initWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
                    @"/etc/hosts", @"filename",
                    nil]] autorelease];
    [[[mailMessage content] paragraphs] addObject:attachment];
        
    [mailMessage setVisible:YES];
    [mail activate];
}
@catch (NSException *e)
{
    NSLog(@"Exception:%@");
}
</pre>

<h3>Error Handling</h3>

I like @try/@catch better than SBApplicationDelegate because the delegate can't easily interrupt the script if there's an error. If you let it raise an exception and then @catch it, the entire block aborts, which is what I generally want. This also exactly matches the normal AppleScript error handling pattern.

<h3>Summary</h3>

Apple has created an incredible new framework with Scripting Bridge, making it easier than ever to tie your application into the system and interact with other programs. Unfortunately, they buried much of the documentation, and left much to the imagination of the reader (like most Applescript documentation). Hopefully this article will help improve that situation and make Applescript a bigger part of your programs.
