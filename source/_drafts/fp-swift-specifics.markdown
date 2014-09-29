---
layout: post
title: "FP Swift Specifics"
comments: true
categories: functional swift
published: false
---
Some concrete points:

* Swift prefers methods over free functions. (This is not a guess. I asked.) Methods auto-complete better and make it easier to discover what a class can do. I am aware (and I'm certain the Swift team is even more aware) of the limitations of methods vs. functions for composition. Swift still prefers methods. There are a lot of limitations on using generics with methods right now. You should expect this to improve rather than for Swift to become more function-centric.

* Swift is operator-light. This goes with preferring methods to free functions. Only punctuation operators are allowed to be infix functions. Punctuation operators introduce a high learning curve when encountering new code. Not all Haskell operators are legal and available in Swift (most critically `<$>` and `>>=`), so introducing operators for those means inventing something unknown to anyone (and *everyone* has picked a different set of replacements).[^bind] The Swift compiler currently has explosive performance behavior on some operators, [particularly `|>`](https://gist.github.com/rnapier/58bb75ac1c67cd5775fc). Operator precedence and associativity are defined globally, opening the opportunity for collisions if frameworks choose different operators. My point is that I think we should go slow with operators and be hesitant to add an operator unless it demonstrates great benefit to Cocoa patterns.

[^bind]: My personal preferences are `<^>` and `>>==`.

* Swift likes its closures at the end. This matches how ObjC typically does things, and coupled with "last closure outside the parens" can, used carefully, lead to some very nice constructs that are easy to read for Cocoa programmers, even if it's not as composable as currying. Work with this, not against it.

* Swift uses ARC. Circular references are a royal pain in ARC. That means some data structures aren't going to port from garbage collected systems. Don't force them. Rethink them.

* Swift likes Cocoa, GCD, Core Data, Core Animation, etc. It seems obvious that the platform will adapt more to Swift idioms, but you should expect Swift to continue to be tightly bound to Cocoa for (at least) the foreseeable future. You should embrace that, not fight it. If Cocoa already does something, make sure to integrate easily with it.