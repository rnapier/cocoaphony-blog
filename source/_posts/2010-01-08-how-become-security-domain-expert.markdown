---
layout: post
status: publish
published: true
title: How to become a security domain expert?
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: "There are many areas of security expertise, so it highly depends on what
  your want your career path to look like. At the bits-and-bytes end there is penetration
  testing and \"security research\" (which is often as much \"cataloging of programming
  bugs\" as actual research). At the more strategic end there is \"risk management\"
  which often spends much of its time in non-technical considerations like appropriate
  budgets, education and response.\r\n\r\nThe most important security tool I used:
  Powerpoint, to make pretty slides that made it clear to the client what they needed
  to understand and implement. And a decent suit. Understanding this stuff is one
  thing. You need have very strong technical skills; that's a given. But actually
  making a *difference* takes a lot of people skills, presentation skills, project
  management and follow-through. It's what separates the 'l33t from the professionals."
wordpress_id: 455
wordpress_url: http://robnapier.net/blog/?p=455
date: 2010-01-08 14:38:45.000000000 -05:00
categories:
- Security
tags:
- Security
---
<em>From a posting on <a href="http://stackoverflow.com/questions/1514102/how-to-become-a-security-domain-expert/1514199#1514199">StackOverflow</a>.</em>

There are many areas of security expertise, so it highly depends on what your want your career path to look like. At the bits-and-bytes end there is penetration testing and "security research" (which is often as much "cataloging of programming bugs" as actual research). At the more strategic end there is "risk management" which often spends much of its time in non-technical considerations like appropriate budgets, education and response.

Blah, blah, blah, but how do you get started, right?<!-- more --> Perhaps the best writer on the subject "big picture" security is [Bruce Schneier][1]. He's a cryptographer, but he focuses on things like the psychology of security, social attacks, and how to really think about security. Crypto-Gram is required reading for how to think correctly in this space.

In the bit-and-bytes areas, you probably want to figure out what area you're most interested in digging into (Windows, wireless, web, physical, iPhone, the list goes on and on). If I had to pick a single paper, though, I'd start with [Smashing The Stack For Fun And Profit][2]. It is still, all these years later, the best introduction to a key class of attack and how technical attacks work in general. If these kinds of attacks are what really interest you, my favorite book on the subject is the [Shellcoder's Handbook][3]. Its attacks are old; many of them won't even work anymore as-is. But they're the basis of how many attacks are still done today.

If you want to move up the "value chain" into "business-centric security" (and learn to use phrases like that without quotation marks), you should begin work on a [CISSP][4]. People can debate till their blue in the face over whether a CISSP actually means anything. The answer is: it means getting the job when CISSP is a requirement. My feelings on the CISSP? Any real security professional should be able to pass it. As such, it is a good *baseline* certification for whether you a real security professional, which is what it's meant to be) It teaches the common terminology that has grown up in the security world, and learning the terminology is part of being a professional (just like in any other profession from law to engineering). The CISSP is very broad, and studying for it will give you a much better idea of what areas interest you, even if you don't ever sit for the test. There are tons of books on CISSP; [All-in-One][5] is fine. Reading this tome will not make you a security expert, but it'll introduce you to what security professionals know.

My background is in risk assessment. For years I traveled to companies, evaluated their environments, and told them what to fix in order to protect their most sensitive information. Probably the most useful training I had for that was the [IAM][6] (the NSA's Infosec Assessment Methodology). It's getting revamped right now into the new ISAM. It focuses on figuring out what pieces of an infrastructure actually matter, and then protecting those. The most important security tool I used: Powerpoint, to make pretty slides that made it clear to the client what they needed to understand and implement. And a decent suit. Understanding this stuff is one thing. You need have very strong technical skills; that's a given. But actually making a *difference* takes a lot of people skills, presentation skills, project management and follow-through. It's what separates the 'l33t from the professionals.

<em>Followup Exercise</em> If you're interested in the wireless security domain, here's your first project: Set up a WEP-encrypted network and learn how to break into it. First, find the script-kiddie tools that will do it for you (they're easily found with google); then figure out how the tools do what they do, and then research why those attacks don't work on WPA. When you're done you'll have a background in the tools of the trade, but also a much better understanding of what's easy and what's hard, and what "WEP is broken" really means for a given network. Are their times that WEP might be acceptable? Why or why not?


  [1]: http://www.schneier.com/crypto-gram.html
  [2]: http://insecure.org/stf/smashstack.html
  [3]: http://www.amazon.com/Shellcoders-Handbook-Discovering-Exploiting-Security/dp/0764544683
  [4]: http://www.isc2.org/
  [5]: http://www.amazon.com/CISSP-Certification-All-Guide-Fourth/dp/0071497870/ref=dp_cp_ob_b_title_0
  [6]: http://www.securityhorizon.com/
