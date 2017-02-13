---
layout: post
title: "Refactoring Slow and Steady"
date: 2017-02-13 12:21:55 -0500
comments: true
categories: 
---

I've been talking with folks on a Slack about refactoring today, and I thought I'd put some of my thoughts here. Maybe a little less polished than I'd like, but I wanted to get them out of my head and down on "paper."

<!--more-->

*The conversation started by referencing the classic Joel piece, [Things You should Never Do, Part I](https://www.joelonsoftware.com/2000/04/06/things-you-should-never-do-part-i/). Leading to my thoughts:*

Just finished some major refactoring work, moving ObjC to Swift and completely redesigning its state machine. I absolutely stand behind the pieces I rewrote (which were a constant source of subtle race conditions and bugs, with every fix causing two new problems). I absolutely stand behind the pieces that I have delayed rewriting (which are a spaghetti mess, and incredibly difficult to safely modify, but after some minor tweaks are stable enough to leave alone).

{% pullquote %}
{" I’m a big fan of "radical refactoring." "} I’ve refactored several code bases until there was almost nothing left of the original code. But it was done steadily, only doing major rewrites to individual pieces after painstakingly detangling them from the rest of the code (usually over the course of several releases). And at the end, there was always some “ball of mud” part that was a bit crazy, but just worked and didn’t need to be touched that often, so we let it be.
{% endpullquote %}

I’ve even refactored a C program into a Go program, by turning it into two independent processes that communicated over sockets, and moving bits from one side of the API to the other.

(So even “we need to switch languages/platforms entirely” doesn’t stop you from evolving towards a goal.)

But there's an exception that Joel doesn’t mention (but I think Martin Fowler does): if you have incredibly *buggy* code, that is, if you *don’t* have working code, then that’s the time to consider a rewrite. Not ugly code. Not badly designed or horrible to work with code. But code that doesn’t actually work, and several attempts to make it work have failed. That’s when a rewrite (at least of those potions) is likely appropriate.

*The discussion then turned to unit testing, and particluarly [Forgotten Refactorings](http://hamletdarcy.blogspot.com/2009/06/forgotten-refactorings.html).*

Having had some very successful radical refactors on code without solid unit test coverage, I think it’s worth discussing how that can be done.

{% pullquote %}
First, unit test coverage is absolutely the best first step. That said, sometimes it is impossible in any meaningful way. When all the most likely and common bugs in your system are race conditions and corner cases involving things outside the program (non-trivial networking, bluetooth, version-specific OS interactions, complex animations, etc), I've found unit tests rapidly become tests of mocks, and not tests of the system. We can debate whether or not it is possible or profitable to redesign your system so it is more testable. I'll even concede that it is and leave arguments about TDD for another day (I'm actually a fan of TDD). But {" redesigning for testablity will *itself* require massive refactoring without unit tests "} (because you can't unit test until you make it testable). Even if you have lots of tests, refactoring often means changing the tests dramatically (which means you're not really testing the same thing). So at *some* point, you're going to find yourself needing to refactor without perfect (or even barely sufficient) unit tests. How do you do it?
{% endpullquote %}

Slow down.

{% pullquote %}
I cannot stress this enough. {" Slow. Down. Expect your refactor to take many releases. "} Do a small piece of refactoring, and run it through a full QA cycle (whatever that means for you) and ship it. Do it again and again. My "convert a C project to Go" project included a release where we just shipped the Go code alongside the C code, without even calling the Go code, just to prove it would install and not break anything. Then we built one, tiny, new feature in the Go code. It was so minor and impacted so few users, we were ready to declare it unsupported if it didn't work. We'd been working on the Go code for almost two years before we cut over to it "for real" (and the vast majority of the code was still in C at that point). But at each step along the way, the system was better, and saner, and more reliable. And at each step along the way, it shipped, and got real field exercise. And we built a lot of tests for it, and we still found bugs that we were unable to build automated tests for. "Fails to determine domain on Mac previously joined to AD domain, but then removed, only on OS X prior to 10.8" or "SMB connection fails to Window 2000 server if username contains space" or "fails to determine correct IP address on Mac with case-sensitive file system if on Cisco VPN." That kind of stuff.
{% endpullquote %}

Second point that goes along with this is to keep your refactor steps contained. I've had so many experimental refactor branches that I threw away because they spiraled out of control and touched too many pieces of the system in non-trivial ways. Don't be afraid to throw away several attempts at refactoring until you can get your change focused enough that the risk is contained. Sometimes that means creating "firebreaks," an object that wraps the thing you're refactoring and provides the old API for code you don't want to touch yet. Creating a firebreak often starts as just a pass-through that does nothing but call methods on the original. Tedious, but often invaluable. They make it possible to move to your new API piece by piece rather than having to touch half the system in one go.

I strongly recommend keeping your commits very focused. "Rename FooAdapter to Foo" should be its own commit. Don't mix it with changes to API. "Rename X to Y" commits are really easy to code review, even if they touch hundreds of files. But if you also changed logic in there, then it's a monster. Similarly, anything that is an easy win with little risk (like naming things sanely, or moving some duplicated code into a function), do those first and get them into the main code base. That way, when you discover that your ambitious new design is out of control and have to start over, you don't lose your easy wins.

{% pullquote %}
Testing is great. Testing is critical. Testing is necessary. But unit testing is not sufficient. And when there are hundreds of test cases that need to be rewritten, they can be a *hindrance* to refactoring. The more important rule in my experience is {" go slow and steady and keep shipping. "}
{% endpullquote %}

And yes. Write your unit tests. We're professionals here.
