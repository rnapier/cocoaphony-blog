---
layout: post
status: publish
published: true
title: Building the Build System - Part 2 - Project Templates
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: "In Part 1 of our series, you learned how to use basic xcconfig files to
  manage build configuration in Xcode rather than using the Build Panel. This is useful,
  but a bit tedious to set up every time you make a new project. What we need is a
  way to automatically create new projects that have our setup in place already. Wouldn’t
  it be nice if you could create new Project Templates just like the ones that come
  with Xcode? You can, and since the release of the iPhone version of Xcode, it’s
  easier than ever. Let’s make one.\r\n"
wordpress_id: 364
wordpress_url: http://robnapier.net/blog/?p=364
date: 2009-05-20 18:00:42.000000000 -04:00
categories:
- builds
tags:
- builds
- xcode
---
In <a href="http://robnapier.net/blog/build-system-1-build-panel-360">Part 1</a> of our series, you learned how to use basic xcconfig files to manage build configuration in Xcode rather than using the Build Panel. This is useful, but a bit tedious to set up every time you make a new project. What we need is a way to automatically create new projects that have our setup in place already. Wouldn't it be nice if you could create new Project Templates just like the ones that come with Xcode? You can, and since the release of the iPhone version of Xcode, it's easier than ever. Let's make one.

<a id="more"></a><a id="more-364"></a>The easiest way to create a new template is to base it off of an existing template. First, let's get a sense of what a project template is, and how Xcode finds and uses them. Open the following directories to see the default templates:

<code>/Developer/Library/Xcode</code> - Mac
<code>/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode</code> - iPhone

As with much of the move in Xcode to <code>/Developer/Platforms</code>, the existing Mac files have been inconsistently transfered, and some are still found in <code>/Developer/Library</code>. Hopefully Apple will get more consistent around this over time.

In these directories, you'll see several templates that should look familiar under File Templates, Project Templates and Target Templates. Let's take a look at the iPhone - Application - Window-Based Application template. You should see the following structure:

<pre>
___PROJECTNAME___.xcodeproj
___PROJECTNAMEASIDENTIFIER____Prefix.pch
Classes/
	___PROJECTNAMEASIDENTIFIER___AppDelegate.h
	___PROJECTNAMEASIDENTIFIER___AppDelegate.m
Info.plist
main.m
MainWindow.xib
</pre>

Basically, it looks very similar to an empty project called <code>___PROJECTNAME___</code> because that's what it is. You could open this project in Xcode, build it and run it. Be a little mindful of doing this; it will create a <code>build</code> directory that you'll want to delete later, but this is basically how we're going to modify our templates.

The one thing special about the template is a little bit of meta-data stored inside the xcodeproj. Open this in Finder (Ctrl-Click and select Show Package Contents). You'll see the standard project.pbxproj, but you'll also see TemplateIcon.icns and TemplateInfo.plist. The first is the icon shown in Xcode, and the latter includes the description of the project (again for the Xcode template chooser screen).

You'll note the use of <code>___PROJECTNAME___</code> versus <code>___PROJECTNAMEASIDENTIFIER___</code>. For the majority of projects these are the same. But if your project has characters that would be illegal in an Objective-C identifier but legal in a file name (spaces, numbers, symbols), then those will be removed in the identifier version. This is important in making class names for instance. So if your project name is "My Application", the xcodeproj will be "My Application.xcodeproj", but the AppDelegate class header will be "MyApplication_AppDelegate.h".

These macros (<code>___PROJECTNAME___</code> and <code>___PROJECTNAMEASIDENTIFIER___</code>) will be substituted anywhere they are found in a filename or within the files. That includes inside of XIB files. So in the MainMenu.xib for a Cocoa project, you can fix the main menu to read "About ___PROJECTNAME___" and it'll be substituted for you. With NIBs, you couldn't do this, which is why "NewApplication" is found all over the place in the Mac MainMenu.xib. It's unfortunate that Apple didn't fix this when they converted the Cocoa templates to XIBs.

There are several other macros available in project templates. These are not documented as far as I know. I've worked them out by looking at the strings in the Xcode framework that provides them, and then testing which ones actually work in project templates (file templates and target templates have slightly different ones).

<pre lang="objc">
___UUIDASIDENTIFIER___
___UUID___
___YEAR___
___ORGANIZATIONNAME___
___FULLUSERNAME___
___USERNAME___
___TIME___
___DATE___
___PROJECTNAMEASXML___
___PROJECTNAMEASIDENTIFIER___
___PROJECTNAME___
</pre>

Note that while there are <code>DATE</code> and <code>YEAR</code> macros, there are no <code>DAY</code> or <code>MONTH</code> macros. <code>ORGANIZATIONNAME</code> is set by default to <code>__MyCompanyName__</code>. You can fix this by setting it in defaults:

<pre lang="bash">
defaults write com.apple.Xcode PBXCustomTemplateMacroDefinitions '{ORGANIZATIONNAME = "My Company"; }'
</pre>

<h3>Walking through it all</h3>

Now that we've talked it to death, let's walk through actually doing it based on our work <a href="http://robnapier.net/blog/build-system-1-build-panel-360">last time</a>.

<ol>
<li>Open <code>~/Library/Application Support/Developer/Shared/Xcode</code> in Finder and make a directory called <code>Project Templates</code>
<li>Under <code>Project Templates</code>, make a directory called <code>iPhone OS</code>.
<li>Open <code>/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Project Templates/Application</code> in Finder.
<li>Copy (don't move), <code>Window-Based Application</code> from the <code>/Developer</code> window to <code>~/Library</code> window.
<li>Open the <code>Window-Based Application</code> folder and open <code>___PROJECTNAME___.xcodeproj</code> in Xcode.
<li>Go back to <a href="http://robnapier.net/blog/build-system-1-build-panel-360">"Abandoning the Build Panel"</a> and apply the changes there. Or apply whatever changes you want to be in every project. In your <code>Application.xcconfig</code>, you'll want this:
<pre lang="objc">
PRODUCT_NAME = ___PROJECTNAME___
GCC_PREFIX_HEADER = ___PROJECTNAMEASIDENTIFIER____Prefix.pch
</pre>
<li>Quit Xcode
<li>Delete the build/ directory if one was created
<li>Right-click the xcodeproj and select "Show Package Contents"
<li>Delete any .mode1v3 and .pbxuser files that may have been created
<li>Open TemplateInfo.plist in Property Editor and set the description as you like
<li>If you like, replace TemplateIcon.icns with an icon file you like
<li>You can now launch XCode, select File>New Project, and you should see a "User Templates" section with your template.
</ol>

If you'd like an example of the project template I use, along with all my xcconfig settings, I've attached it. We'll be discussing some of these settings in the future.

<a href="http://robnapier.net/blog/wp-content/uploads/2009/05/projecttemplates.zip" title="ProjectTemplates.zip">ProjectTemplates.zip</a>
