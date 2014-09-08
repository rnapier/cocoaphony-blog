---
layout: post
title: "Code is technical writing (plus a compiler)"
date: 2014-06-16 16:19:14 -0400
comments: true
categories: 
---
Good coding practices are those that make it easier to...

1. write correct code (i.e. discourage behaviors that are likely to create new bugs)
2. detect incorrect code (i.e. make it easier to code review and debug)
3. understand and modify code, while maintaining its correctness
4. reuse code in other projects while still keeping these properties

I consider other concerns secondary. For example, I believe it's much more
important that it be easy to write correct code than it be easy to write fast
code.

So what about "shortness" of code? It's the same as in other kinds of
technical writing (and source code is a kind of techincal writing, with an
audience of both programmers and compilers). It should be concise and to the
point, but the first concern is not the number of letters the author must
write. Good code should be the same. Extraneous details, obvious to the
reader, should eliminated. But important details should not be omitted. And as
in technical writing, assume that the reader may have jumped into this section
without reading everything that came before. Yes, that means you occassionally
repeat yourself. That is not a sin in writing or in code.

Write with an eye to how it will be read. Since much code review is done with
contextual diffs, your code should be understandable with limited context and
without an IDE. Most importantly, incorrect code should be easy to spot with
limited context. This is best done by making suspicious things look
suspicious.

Prior to ARC, the single most common cause of crashes in ObjC was directly
accessing ivars rather than going through accessors. I saw this again and
again in various product teams, with students, and on StackOverflow. It is
just too easy to mess up retains and releases if you do them all by hand. But
ObjC memory management is quite simple if you always use accessors. So when a
program was crashing, the first place I always looked was for direct ivar
accesses. But how do you find them? If I see `foo = bar`, is it a bug? If
`foo` is a local variable it's probably correct. If it's an ivar, I need to
dig in. How do I know?

Over the years, ObjC developers learned to put an underscore on the front of
ivars (eventually, Apple even made this automatic). Then `_foo = bar` is
suspicious. Why are you messing with an ivar directly? You have a much better
chance of finding the bug. That underscore (and using `self`) meant a few more
letters to read and write, but it saved us many bugs by making the code much
more clear and making suspicious things look suspicious. That's what good
practice looks like.

But it worked the other way too. It's somewhat common in ObjC for accessors to
have side effects. Sometimes they post notifications, or put things on a
dispatch queue, or fire a KVO. And this can be a source of bugs as well. I've
encountered several cases wher accessors lead to reentrance bugs because a
notification fired and was posted to another thread. In those cases, it's very
useful that ObjC requires `self` on accessors. When you're reading through the
code, `_foo = bar` may be suspicious for memory management, but you know
nothing else is happening. When you see `[self setFoo:bar]` in the middle of
code that seems to be deadlocking, that's a very good place to go looking for
side effects.[^dot-notation] Again, suspicious code looks suspicious, whether
it's because it calls a function it shouldn't or because it doesn't call a
function it should.

[^dot-notation]: This is a major reason that dot notation frustrates older ObjC developers, even those who use it. It obscures the fact that there's a function call, which leads to a lot of confusion when there are side effects. We've gotten used to it over the years, but you used to be able to search your code for `setFoo:` and find all the setters. It's harder now, and more confusing that it used to be.

Code sometimes is more like fiction. Imagine you are writing a book together
with other authors. You're all writing your own chapters, but the plot and
characters need to stay consistent. It's quite a challenge. It's easier if
the characters have very very simple backstories, simple motivations, and
follow a simple patterns. It's easier to write for Murder She Wrote 

Swift opens new doors for conciseness, but also for obfuscation. Some advice
from the C++ world: think long and hard before you overload an operator. Will
the overload make it easier or harder for a reviewer to know what your code is
doing? Like acronyms, sometimes the shorter form is much easier to understand,
especially if used very often and replacing something very long (like "dynamic
host configuration protocol" versus "DHCP"). But sometimes it becomes a
confusing soup of symbols. Make your decision based on clarity to the reader,
not efficiency of keystrokes.
