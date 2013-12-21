---
layout: post
status: publish
published: true
title: Building the Build System - Part 1 - Abandoning the Build Panel
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: XCode has a decent build system, but it doesn't work as well as it could
  out of the box. With just a little work, you can make your projects easier to setup
  and maintain just the way you want them, improve your code, and even speed up your
  build times. In this section, we'll learn how to replace the XCode Build Panel with
  xcconfig files.
wordpress_id: 360
wordpress_url: http://robnapier.net/blog/?p=360
date: 2009-05-14 08:00:59.000000000 -04:00
categories:
- builds
tags:
- builds
- xcode
- xcconfig
---
XCode has a decent build system, but it doesn't work as well as it could out of the box. With just a little work, you can make your projects easier to setup and maintain just the way you want them, improve your code, and even speed up your build times.

The first thing we want to do is get rid of one of the great obfuscations of Xcode: The Build panel.

<img src="http://robnapier.net/blog/wp-content/uploads/2009/05/buildpanel-300x274.png" alt="Build Panel" title="Build Panel" width="300" height="274" class="alignnone size-medium wp-image-353" />

The build panel seems convenient at first, but in practice it makes it hard to see what's going on in your build. It especially gets confusing as your build settings get complicated. When you need to turn off Thumb Code Generation because of an obscure assembler conflict in legacy C++ code (true story), it would be nice to put a comment somewhere indicating why you've done this so someone doesn't come along later switch the setting. The Build Panel doesn't give you an easy way to include comments right along with the setting (the "Comments" panel is pretty useless in my experience), and it's easy to lose settings or accidentally apply them to only to one configuration.

XCode provides a better solution called xcconfig files. Everything you can do in the build panel can be done in xcconfig files, and you can actually read them and make comments. So let's make some.
<a id="more"></a><a id="more-360"></a><ol>
	<li>Create a new Window-Based iPhone Application. (Everything we do here works exactly the same for Mac.)</li>
	<li>Add a new group to your Groups & Files called "Build Configuration".</li>
	<li>Add a new file to the group. Under "Other" select "Configuration Settings File." Call it "Shared.xcconfig".</li>
	<li>Create three more xcconfig files called Debug, Release and Application.
	<li>Double-click the Project to open the Project Info panel, and select Build.</li>
	<li>Select Configuration: "Debug" and Show: "Settings Defined at This Level."</li>
	<li>Select all the settings (you can use Cmd-A here).</li>
	<li>Copy them with Cmd-C.</li>
	<li>Go back to Debug.xcconfig and paste with Cmd-V. You now know how to find out the xcconfig syntax for any Build Panel setting you're uncertain of.</li>
	<li>Go back to the Build Panel and hit Delete to set all settings to default. Select "Show: All Settings" so you can see your settings again.</li>
	<li>In the lower-right of the panel, for "Based On:" select "Debug." You should see your old settings show back up, but not bold this time.</li>
	<li>Repeat for Configuration: "Release". Copy them to Release.xcconfig and delete them from the Build Panel.</li>
	<li>Double-click on the Target, and repeat the process, moving both its Debug and Release settings to Application. Put in a comment to indicate which are the Debug settings and which are the Release settings. We'll clean them up shortly. Select "Configuration: All Configurations" and "Based On: Application."</li>
</ol>
We've now moved everything from the build panel to the xcconfig files, and the system should build. Debug and Release are slightly confused because we mixed the settings in Application, but we'll fix that now.

Look in Application.xcconfig, and move anything that's in Debug but not in Release to Debug.xcconfig, and anything in Release but not Debug to Release.xcconfig. Anything that's in both, delete the second copy of. 

Anything that is in both Release and Debug, move to Shared, and put <code>#include "Shared.xcconfig"</code> at the top of the Release and Debug configs.

If you've followed all the instructions, you should have four files that look like this (assuming your product's name is "Test"):

<h4>Shared.xcconfig</h4>
<pre>
ARCHS = $(ARCHS_STANDARD_32_BIT)
SDKROOT = iphoneos2.2.1
CODE_SIGN_IDENTITY = 
CODE_SIGN_IDENTITY[sdk=iphoneos*] = iPhone Developer
PREBINDING = NO
GCC_C_LANGUAGE_STANDARD = c99
GCC_WARN_ABOUT_RETURN_TYPE = YES
GCC_WARN_UNUSED_VARIABLE = YES
</pre>

<h4>Release.xcconfig</h4>
<pre>
\#include "Shared.xcconfig"
COPY_PHASE_STRIP = YES
</pre>

<h4>Debug.xcconfig</h4>
<pre>
\#include "Shared.xcconfig"
ONLY_ACTIVE_ARCH = YES
COPY_PHASE_STRIP = NO
GCC_DYNAMIC_NO_PIC = NO
GCC_OPTIMIZATION_LEVEL = 0
</pre>

<h4>Application.xcconfig</h4>
<pre>
INFOPLIST_FILE = Info.plist
PRODUCT_NAME = Test
ALWAYS_SEARCH_USER_PATHS = NO
GCC_PRECOMPILE_PREFIX_HEADER = YES
GCC_PREFIX_HEADER = Test_Prefix.pch
</pre>

If you Build&Run now, everything should work. It's not a great build configuration, but it's Apple's default in a form that we can start understanding and improving.

But before that, we're going to convert this to a Project Template, so we don't have to go through this process again. We'll do that in the <a href="http://robnapier.net/blog/project-templates-364">next part of this series</a>.
