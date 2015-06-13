---
layout: post
title: "Some initial thoughts on guards"
date: 2015-06-13 13:13:55 -0400
comments: true
categories: 
---

Been contemplating Swift guard style a little. IMO, it's a no-brainer at the top
of longish functions. Please, exit early on errors. Don't nest the whole world
in three levels of if-let. Putting the error leg near the test is much better
than burying it down at the bottom of the function.

The question to me is in shortish things. For example, I find this extremely
clear and readble:

    for _ in 1...n {
        if let next = g.next() {
            result.append(next)
        } else {
            break
        }
    }

But it could also be written this way:
    
    for _ in 1...n {
        guard let next = g.next()
            else { break }
        result.append(next)
    }
 
At first glance, I find that slightly less readable and so initially discounted
it. But it has an advantage. Guard *forces* you to exit scope. You can't forget
to and accidentally fall-through. In the `if` example, if I'd forgotten the
`break` (accidentally deleted it, replaced it with logging, whatever), that
would still be legal, but wrong. In this case it would actually generate
undefined behavior because it would call `next()` after `nil`. That quietly
"works" for most sequence types, but is not defined (which means that unit test
probably wouldn't catch the bug).

I suspect that the "slightly less readable" is mostly due to familiarity. Your
eyes get used to what to skip over in code, what's important and what's
decoration. I think my eyes have gotten used to the string `if let` enough to
treat it as a single unit, but just haven't gotten to reading `guard let` that
way yet.

I've played with other layouts, and sometimes putting the `else` on the same
line is nice, but it can also bury the core code a little:

    for _ in 1...n {
        guard let next = g.next() else { break }
        result.append(next)
    }

That said, that style is growing on me for short things like this. And I am
leaning more towards using `guard` as the default choice if the `else` leg would
bail out of scope. That makes it clearer that `if let` *doesn't* bail out of
scope, and I think that's nice.

But still learning. Time will tell.
