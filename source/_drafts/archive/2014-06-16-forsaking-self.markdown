---
layout: post
title: "Forsaking Self"
date: 2014-06-16 09:29:09 -0400
comments: true
categories: 
---
*or... "Why I Agree With Andy Matuschak, But Would Rather Fix Swift"*

[Justin Spahr-Summers](https://twitter.com/jspahrsummers), 
[Andy Matuschak](http://andymatuschak.org), and I had a
[brief Twitter exchange](https://twitter.com/jspahrsummers/status/478055530036875264)
a few days ago about when you should use `self`. These are smart guys who I've
been listening to for a long time now, and I'm not saying they're not right.
I'm just saying it's a mistake in the language that should be fixed.

Some background: Swift currently allows but does not require `self.` to refer
to an object's own properties and methods. So the question is: what rules
should Swift programmers use to decide whether to include `self.`, or should
Swift be changed to require it?

### Some principles

We need to agree first on a few principles. If you disagree with these things,
we're never going to agree on the end result. But I hope these principles
aren't particularly controversial among professional programmers in any
language, and particularly among ObjC developers.

Good coding practices are those that make it easier to...

1. write correct code (i.e. discourage behaviors that are likely to create new bugs)
2. detect incorrect code (i.e. make it easier to code review and debug)
3. understand and modify code, while maintaining its correctness

I consider other concerns secondary. For example, I believe it's much more
important that it be easy to write correct code than it be easy to write fast
code.

So what about "shortness" of code? It's the same as in other kinds of
technical writing (and source code is kind of techincal writing, with an
audience of both programmers and compilers). It should be concise and to the
point, but the first concern is not the number of letters the author must
write. Good code should be the same. Extraneous details, obvious to the
reader, should eliminated. But important details should not be omitted. And as
in technical writing, assume that the reader may have jumped into this section
without reading everything that came before.

So all of this is just to dispel the possible answer "do whichever takes fewer
keystrokes."
