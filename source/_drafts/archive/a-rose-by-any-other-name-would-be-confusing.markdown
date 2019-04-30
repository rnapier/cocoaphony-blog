---
layout: post
title: "A rose by any other name would be confusing"
comments: true
published: false
categories: 
---
Sometimes the same meaning can have many names or symbols. We all deal with the
fact that `×` is the same as `*`, and `÷` is the same as `/`, but the more
arbitrary names and symbols are attached to a concept, the harder it is to share
information. 

Avoid creating new names for old ideas unless you have a very good reason. That
means you should do a bit of study before you start creating new things. This
especially holds true of operators, since they're so arbitrary. Haskell has a
*lot* of operators defined, and it's the place that experienced functional
programmers tend to look first. If you're coming up with a new operator, try not
to conflict with Haskell, and when possible, use the Haskell operator if it
means exactly what you're doing. It's the best way for others to be able to read
your code and to interoperate with other code bases. Even if you can't read
Haskell yet, you can look up operators in [Hoogle](http://www.haskell.org/hoogle/).[^hoogle]

[^hoogle]:Hoogle is good for looking up whether an operator exists, but unfortunately if you can't read Haskell, its descriptions will be completely meaningless.

`>>==` is an unfortunate case. The Haskell operator is `>>=`, but that's 
bit-shift assign in Swift. Overloading it for a completely different purpose
could be confusing and created compilation problems when I tried it. So I
replaced it with `>>==` after trying several other options (including `>>>` from
[Tony DiPasquale](http://robots.thoughtbot.com/efficient-json-in-swift-with-functional-concepts-and-generics)
and `>>=-` from [Alexandros Salazar](http://nomothetis.svbtle.com/the-culmination-i)).
I think `>>==` looks the most like Haskell's, while being easy to type and read 
in a variety of fonts. Maybe some other operator will win in the end, but `>>==`
is my suggestion.

