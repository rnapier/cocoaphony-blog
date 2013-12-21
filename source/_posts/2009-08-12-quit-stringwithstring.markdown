---
layout: post
status: publish
published: true
title: 'Quit using +stringWithString:'
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: "I keep coming across [code](http://dotnetaddict.dotnetdevelopersjournal.com/leopard_nscollectionview.htm)
  like this:\r\n\r\n    newMonster.trueName = [NSString stringWithString:@\"New Monster\"];\r\n\r\nIt's
  time to say stop it already with the extra `+stringWithString:`. I haven't worked
  out yet where this anti-pattern comes from. Maybe it's a misunderstanding of some
  sample code in [Kochan](http://www.amazon.com/Programming-Objective-C-Developers-Library-Stephen/dp/0672325861)?
  Maybe it's a Java/.NET thing? I'm not sure. But I see it so often from so many places
  that it's clearly something that needs discussing. (The rest of the linked article
  is good; it just gave me a good example of this issue.)\r\n\r\n"
wordpress_id: 415
wordpress_url: http://robnapier.net/blog/?p=415
date: 2009-08-12 10:48:10.000000000 -04:00
categories:
- cocoa
tags: []
---
I keep coming across [code](http://dotnetaddict.dotnetdevelopersjournal.com/leopard_nscollectionview.htm) like this:

    newMonster.trueName = [NSString stringWithString:@"New Monster"];

It's time to say stop it already with the extra `+stringWithString:`. I haven't worked out yet where this anti-pattern comes from. Maybe it's a misunderstanding of some sample code in [Kochan](http://www.amazon.com/Programming-Objective-C-Developers-Library-Stephen/dp/0672325861)? Maybe it's a Java/.NET thing? I'm not sure. But I see it so often from so many places that it's clearly something that needs discussing. (The rest of the linked article is good; it just gave me a good example of this issue.)

<a id="more"></a><a id="more-415"></a>
The correct form of the above code is:

    newMonster.trueName = @"New Monster";

Now isn't that easier? `@"Blah"` is an NSString object. Full object. Does everything an NSString can do:

    NSString *foobar = [@"foo" stringByAppendingString:@"bar"];

It's secretly a private subclass of NSString called NSConstantString, but that doesn't matter for this purpose. In proper OOP, a subclass is as good as its parent. If it isn't, then the model is broken.

Now, that leads us to NSMutableString. I sometimes see this code, and sometimes it's right and sometimes it's wrong:

    NSString *string = [NSString stringWithString:mutableString];

This code is wrong if you're going to return `string`. If the caller expected an NSString and you return an NSMutableString, that's fine. There is no reason to make an extra copy just to change the type; it's a waste of time and memory.

BUT... there's another case. What if someone passes you an NSMutableString when you expect an NSString? If you're going to retain that object, it's a good idea to make a copy. That way if the caller modifies the string later, your copy doesn't change behind your back. Consider this code:

~~~~
NSMutableString *ms = [@"foo" mutableCopy];
anObject.foo = ms;
[ms appendString:@"bar"];
anObject.foobar = ms;
~~~~

In this case, anObject would be very surprised that its `foo` property suddenly held "foobar". The fix to that is to use `-copy` in `-setFoo:`. `+stringWithString:` would be ok in this case, but I prefer `-copy` because it's shorter, clearer to me, and almost certainly faster at least in some cases. This is why I recommend using the "copy" attribute on public properties that have well-known mutable subclasses (NSString, NSArray, NSSet, etc.)

You'll note that I used `-mutableCopy` above to create the NSMutableString. I did that just to show how to use `-mutableCopy`. Generally for initializing an NSMutableString to a constant string, I'd use `+stringWithString:`, which is what this method is really for: creating an NSString *subclass* with an NSString. But you should never need `+stringWithString:` to create an NSString itself.
