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
In [Part 1](/blog/build-system-1-build-panel) of our series, you learned how to use basic xcconfig files to manage build configuration in Xcode rather than using the Build Panel. This is useful, but a bit tedious to set up every time you make a new project. What we need is a way to automatically create new projects that have our setup in place already. Wouldn't it be nice if you could create new Project Templates just like the ones that come with Xcode? You can, and since the release of the iPhone version of Xcode, it's easier than ever. Let's make one.

<!-- more -->

`/Developer/Library/Xcode` - Mac
`/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode` - iPhone

As with much of the move in Xcode to `/Developer/Platforms`, the existing Mac files have been inconsistently transfered, and some are still found in `/Developer/Library`. Hopefully Apple will get more consistent around this over time.

In these directories, you'll see several templates that should look familiar under File Templates, Project Templates and Target Templates. Let's take a look at the iPhone - Application - Window-Based Application template. You should see the following structure:

```
___PROJECTNAME___.xcodeproj
___PROJECTNAMEASIDENTIFIER____Prefix.pch
Classes/
	___PROJECTNAMEASIDENTIFIER___AppDelegate.h
	___PROJECTNAMEASIDENTIFIER___AppDelegate.m
Info.plist
main.m
MainWindow.xib
```

Basically, it looks very similar to an empty project called `___PROJECTNAME___` because that's what it is. You could open this project in Xcode, build it and run it. Be a little mindful of doing this; it will create a `build` directory that you'll want to delete later, but this is basically how we're going to modify our templates.

The one thing special about the template is a little bit of meta-data stored inside the xcodeproj. Open this in Finder (Ctrl-Click and select Show Package Contents). You'll see the standard project.pbxproj, but you'll also see TemplateIcon.icns and TemplateInfo.plist. The first is the icon shown in Xcode, and the latter includes the description of the project (again for the Xcode template chooser screen).

You'll note the use of `___PROJECTNAME___` versus `___PROJECTNAMEASIDENTIFIER___`. For the majority of projects these are the same. But if your project has characters that would be illegal in an Objective-C identifier but legal in a file name (spaces, numbers, symbols), then those will be removed in the identifier version. This is important in making class names for instance. So if your project name is "My Application", the xcodeproj will be "My Application.xcodeproj", but the AppDelegate class header will be "MyApplication_AppDelegate.h".

These macros (`___PROJECTNAME___` and `___PROJECTNAMEASIDENTIFIER___`) will be substituted anywhere they are found in a filename or within the files. That includes inside of XIB files. So in the MainMenu.xib for a Cocoa project, you can fix the main menu to read "About ___PROJECTNAME___" and it'll be substituted for you. With NIBs, you couldn't do this, which is why "NewApplication" is found all over the place in the Mac MainMenu.xib. It's unfortunate that Apple didn't fix this when they converted the Cocoa templates to XIBs.

There are several other macros available in project templates. These are not documented as far as I know. I've worked them out by looking at the strings in the Xcode framework that provides them, and then testing which ones actually work in project templates (file templates and target templates have slightly different ones).

```
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
```

Note that while there are `DATE` and `YEAR` macros, there are no `DAY` or `MONTH` macros. `ORGANIZATIONNAME` is set by default to `__MyCompanyName__`. You can fix this by setting it in defaults:

``` bash
defaults write com.apple.Xcode PBXCustomTemplateMacroDefinitions '{ORGANIZATIONNAME = "My Company"; }'
```

### Walking through it all

Now that we've talked it to death, let's walk through actually doing it based on our work [last time](/blog/build-system-1-build-panel).

* Open `~/Library/Application Support/Developer/Shared/Xcode` in Finder and make a directory called `Project Templates`
* Under `Project Templates`, make a directory called `iPhone OS`.
* Open `/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Project Templates/Application` in Finder.
* Copy (don't move), `Window-Based Application` from the `/Developer` window to `~/Library` window.
* Open the `Window-Based Application` folder and open `___PROJECTNAME___.xcodeproj` in Xcode.
* Go back to ["Abandoning the Build Panel"](/blog/build-system-*-build-panel) and apply the changes there. Or apply whatever changes you want to be in every project. In your `Application.xcconfig`, you'll want this:
```
PRODUCT_NAME = ___PROJECTNAME___
GCC_PREFIX_HEADER = ___PROJECTNAMEASIDENTIFIER____Prefix.pch
```
* Quit Xcode
* Delete the build/ directory if one was created
* Right-click the xcodeproj and select "Show Package Contents"
* Delete any .mode1v3 and .pbxuser files that may have been created
* Open TemplateInfo.plist in Property Editor and set the description as you like
* If you like, replace TemplateIcon.icns with an icon file you like
* You can now launch XCode, select File>New Project, and you should see a "User Templates" section with your template.

If you'd like an example of the project template I use, along with all my xcconfig settings, I've attached it. We'll be discussing some of these settings in the future.

[Project Templates at Github](https://github.com/rnapier/cocoaphony/tree/master/Project%20Templates)
