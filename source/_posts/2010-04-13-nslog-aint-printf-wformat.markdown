---
layout: post
status: publish
published: true
title: NSLog ain't printf in -Wformat
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: You'd think that printf("%s", 1) and NSLog(@"%s", 1) would throw the same
  warnings. But you'd be wrong. The compiler can't handle it.
wordpress_id: 477
wordpress_url: http://robnapier.net/blog/?p=477
date: 2010-04-13 11:45:15.000000000 -04:00
categories:
- cocoa
- iphone
tags: []
---
So say you had this code:

    printf("%s", 1);
    NSLog(@"%s", 1);

And you compiled with `-Wformat`. You might expect both of these lines to kick out a warning:

    Format '%s' expects type 'char *', but argument 2 has type 'int'

You'd be particularly misled when you went and looked at the definition of `NSLog()`:

    FOUNDATION_EXPORT void NSLog(NSString *format, ...) __attribute__((format(__NSString__, 1, 2)));

Why look there, doesn't that look like it should provide format type checking? Oh how foolish. Neither gcc nor clang can actually handle that `__NSString__` specifier in a robust way. So the first line above will give a useful warning, but the second one will silently compile and later crash. Exciting, I know. You have been warned.

 `-Wformat-nonliteral` and `-Wformat-security` do catch dangerous calls like `NSLog(foo)`, so `__NSString__` isn't a complete loss, but it's a shame we can't get type checking here.

There's a good discussion of this at [NSLog(…) improper format specifier affects other variables?](http://stackoverflow.com/questions/1229212/nslog-improper-format-specifier-affects-other-variables])
