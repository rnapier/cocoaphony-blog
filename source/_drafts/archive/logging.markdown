---
layout: post
title: "Logging"
comments: true
published: false
categories: 
---

Before your code ships, the most important bug-squashing tools available are ubiquitous code review and consistent naming. But *after* your code ships, the most important bug-squashing tool available is logs.

I've got a lot of opinions on logging, and my first few attempts to write this have gotten really long-winded, so I'm going to take a little more case study approach and talk about my current approach and why I like it. I'm going to limit myself to talking about Swift on iOS, but much of this can apply to many other systems (and I've used this same approach on a lot of languages and platforms).

We'll start with an example of what logging looks like for me. I'm going to show some code, but I don't intend to release this entire package. This is an article about building your own logging systems, not releasing a new open source framework.

    Log.trace("Changing state", data: ["from": state, "to": newValue])
