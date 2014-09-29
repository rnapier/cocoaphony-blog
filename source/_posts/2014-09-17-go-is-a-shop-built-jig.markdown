---
layout: post
title: "Go is a shop-built jig"
comments: true
date: 2014-09-17 15:50
categories: go swift
---

[Alex Payne](https://al3x.net/about.html) wrote an excellent essay called [Thoughts on Five Years of Emerging Languages](https://al3x.net/2014/09/16/thoughts-on-five-years-of-emerging-languages.html). It called to mind something I wrote a while ago for a limited audience that I never got around to turning into a public form. Thanks to [Manuel Chakravarty](https://twitter.com/TacticalGrace) for the link and the inspiration.

For those who read my blog for Cocoa (and recently Swift) discussion, you may be surprised that most of my professional work right now is in Go, C, and C++ (in that order). So I thought I might take a moment to discuss Go.

First, it's important to say that I really like Go. I didn't think I would. I'm a language snob at heart. Before Swift, I'd been spending a lot of time on the [functional](http://learnyouahaskell.com) side of the [street](http://www.scala-lang.org) with a brief dallience with [actors](http://akka.io). I was just about to do deeper [into the parens](http://clojure.org), when I wound up taking a side trip into Google-land and Go. I'd dipped my toe into the water once before and been turned off by what seemed to be the sloppiness of the language. How variables are declared bugged me (turns out it [bugs the lead language designer](http://gophercon.sourcegraph.com/post/83845316771/panel-discussion-with-go-team-members), too). The multiple return types of `range` bugged me. [Strings switching between code points and bytes](http://blog.golang.org/strings) bugged me. The fact that Go can't implement its own `append()` harkened back to funky Perl magic. Go just seemed sloppy and under-considered.

<!-- more --> 

But a coworker made a joke about rewriting an important service in Go, and after laughing about it, I thought I'd at least take another look. It turned out to be a great fit. Go's bread-and-butter is concurrent network services, which is what we wanted to solve. So I dug a bit more.

-   Very cross-platform out of the box.
    -   Not "sort-of cross-platform as long as it's unix" like C/C++. Real-world Windows support is pretty good. No wchar/tchar/char madness.
-   Built-in cross-platform networking support that integrates with the native stack.
-   Native binaries. No need to ship a separate interpreter, runtime, or VM.
-   Handles concurrency very well.
-   Pretty easy to pick up for C programmers

It was a good fit. I went ahead and reworked the system in Go. I've been very happy with the results so far.

{% pullquote %}

So what have I learned by actually building something? {" Go feels under-engineered because it only solves real problems. "} If you've ever worked in a wood shop, you've probably made a jig at some point. They're little pieces of wood that help you hold plywood while you cut it, or spacers that tell you where to put the guide bar for a specific tool, or hold-downs that keep a board in place while you're working on it. They're not always pretty. They often solve hyper-specific problems and work only with your specific tools. And when you look at ones that have been used a lot, they sometimes seem a little weird. There might be a random cutout in the middle. Or some little piece that sticks off at an angle. Or the corner might be missing a piece. And when you compare them to "real" tools, "general" tools like you'd buy from a catalog, they're pretty homey or homely depending on how you're thinking about it.

{% endpullquote %}

But when you use one of them in your shop, you learn that the random cutout is because you store it against the wall and it would block the light switch otherwise. And if you put your hand on that little extra piece that sticks out, then the board won't fall at the end of the cut. And the corner… well the corner is where you messed up when you were first making it and it's kind of ugly, but it never actually matters when you use it. And that's Go. Not a single thing I mentioned in the first paragraph has actually come up as a problem. Its really good at solving the problems that it solves, which happen to be very common problems for people who need to ship software, especially networking software.

Probably the biggest complaint people have with Go is the lack of generics. And I did run into that in just the first couple of weeks of work on my project, and I wound up with a bunch of duplicated code to work around it. And then, when it was all working, I refactored out the duplicated code. And I refactored again. And in the end, the whole thing was simpler and shorter than what I would have done with generics. So again, in the end, Go turned out to be a language for solving real problems rather than a language filled with beautiful tools, and so you build real solutions rather than finding excuses to use your beautiful tools. Don't try to make Go what it isn't. If you're trying to solve abstract CS problems in their most generalized forms, then you may find it frustrating. But if you're trying to solve specific, practical problems in the forms professional developers typically encounter, Go is quite nice.

I recently wrote some Go code that looked basically like this:

```
func (f *Frobulator) frobulate() error {
  if f.thingsToFrobulate > 0 {
    var err error

    if err = logit(FrobulatingMessage); err != nil {
      return err
    }

    if err = f.cleanupOldest(); err != nil {
      return err
    }

    var youngest Frobable
    if youngest, err = f.processOld(); err != nil {
      return err
    }

    if err = f.doNewThing(youngest); err != nil {
      return err
    }
  }

  return f.cleanup()
}
```

There's a lot of boilerplate duplication there with some "almost the same, but kinda different" stuff in the middle that feels awkward.

If I were writing this in Swift with my [LlamaKit](https://github.com/LlamaKit/LlamaKit) bells-and-functional-whistles, I might write it as:

```
func frobulate() -> Result<Void> {
  var result = success(())
  if self.thingsToFrobulate > 0 {
    result = logit(FrobulatingMessage)
      >>== self.cleanupOldest
      >>== self.processOld
      >>== self.doNewThing
  }
  return result >>== self.cleanup
}
```

The Swift+LlamaKit version is half as long, and almost every line is focused on the task at hand. It feels much more elegant. There is far less duplication. But there's a pretty big story in how these two functions were written.

When writing the Swift function, I found myself spending a lot of time thinking about how to write it. Should I use `>>==` or `.flatMap()`? Should I use my custom `Result` here at all, or should I stick to standard Swift and return `NSError?`, or maybe `Bool` with an `NSErrorPtr`? This was my first time using `Result<Void>`, and I started asking myself if I should create a typealias for that and maybe a helper function for the slightly strange looking `success(())`. The `var` bothered me. It always feels like a hack in FP, like you're not smart enough to do it right. I wrote a different version that didn't have a `var`. That duplicated `self.cleanup` in two places. So I started working on a new function that would let me include the conditional in the functional composition. I made and re-made a lot of choices. [^swift]

[^swift]: The underlying issue here isn't that I chose to use special operators out of LlamaKit. I could have written the Swift code in [the same style as the Go code](https://gist.github.com/rnapier/27ba98c827c9d7798879) or in [traditional ObjC style](https://gist.github.com/rnapier/4a48b24024ff969f2e94). The point is that there are lots of ways you could do it, and lots of ways different Swift developers will *choose* to do it because the language is very flexible and there is no obvious "Swift way."

{% pullquote %}

{" When writing the Go function, I started at the top and typed until I got to the bottom. "} And that was it. There aren't very many ways to write this function in Go. I expect that most Go programmers, given the same set of helper functions, would have written it almost identically. Because of gofmt, I don't even make formatting decisions.

{% endpullquote %}

I could probably spend another hour polishing my dozen-line Swift function and building generic tools to make it easier in the future for people (at least those who use my toolkits) to write this kind of code beautifully.

Or I could write it in Go in about 2 minutes and move onto fixing the next bug in the backlog.

I admit, I would rather spend my time writing generic, elegant functions that help developers think deeply and correctly about their programs. Like Alex, falling back on for-loops and mutable state makes me feel like a bad programmer. But there is a certain tension between all that and shipping things today.

Did I mention Go compiles *really fast*?

But late at night, when it's my own time for my own projects, it's Swift I'd rather work in.