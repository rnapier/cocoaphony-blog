---
layout: post
title: "Unicode: Code points"
published: true
categories:
---

I want to spend a few posts talking about one of my favorite topics, Unicode. Eventually I'll get to the one corner of Unicode that [everyone cares about](https://www.imdb.com/title/tt4877122/), but for now, indulge me while I ramble on about all the incredible work that has gone into bringing human writing systems to computers.

Humans like to write things down, and over the last several thousand years, we’ve developed a wide variety of ways to do that. And then, over the last century, we started building computers. And computers work with numbers, which doesn't line up well with how humans write things down. For decades, we developed systems for encoding human writing into numbers so that computers could work with it.

And at the heart of all of them is the code point.

<!-- more -->

The code point is the most basic unit of text in a computer encoding system. Ultimately, computers work with numbers, so we have to have a way to turn letters and symbols and punctuation and diacritics and all the rest into numbers, and code points are how we do that. Probably the most famous code point mapping is ASCII.

ASCII maps a 7-bit number, from 0 to 127, to the basic Latin alphabet, upper and lower case, plus the Arabic numerals, some punctuation, and some control characters that were used mostly by old Teletype machines.

Now, the obvious problem with ASCII is that the basic Latin alphabet isn’t enough for even most languages that use the Latin alphabet, let alone all the other languages in the world, and so there were a ton of different, incompatible ways to encode the things different groups felt were most important to them.

And all that led, in the 1980s and early 90s, to Unicode, which intends to be a single, unified, mapping of numbers to “language thingies” for every human writing system.

What do I mean “language thingy?” Well. It’s complicated.

## The Language Thingy

According to Unicode, code points map to “abstract characters.” What does that mean? Well, it basically means “the things Unicode code points map to.” But the intention is that an abstract character is a fundamental unit of written language that’s independent of precisely how it’s drawn.

Picture in your mind a lowercase *x* with an acute accent. If you're comfortable with Latin-using language (and I assume you must be), that's probably pretty easy to imagine.

But that's kind of strange. I don't think there's any language in the world that uses that symbol. And yet, we probably all agree on what it would look like if we did. That tells us that "lowercase x" and "with an acute accent" are probably abstract, composable pieces among Latin-using cultures.

The "abstract" is important. [There are many ways that you could draw x and "acute accent" and have them be understood.](https://fonts.google.com/?preview.text=xx́&preview.text_type=custom&category=Display,Handwriting) The goal of Unicode code points is to capture the essence and meaning of the mark rather than the specific way it's drawn.

Now Unicode is wildly inconsistent about exactly how this idea is applied, and really there’s no universally consistent way you could apply it. Unicode is the way it is for many reasons. Backward compatibility with older systems, global politics, mistakes, and frankly, human writing systems are deeply messy, and so anything that tries to encode them is going to be deeply messy. But the idea is that there are these abstract pieces of human writing, independent of exactly how their drawn, that each code point represents.

## Encoding code points

In Unicode, these code points are 21 bit numbers, ranging from 0x00000000 - 0x7FFFFFFF (0 - 2,147,483,647).

21 bits seems strange. Most computer-numbers are a power of two, and not only is 21 not itself a power of two, but when put into 8-bit bytes, it needs 3, which *also* isn't a power of two. But as I said, many things about Unicode are the way they are because of its history. Originally, Unicode (specifically UCS-2) was encoded in 16 bit code points. That turned out to be far too small




We need a way to write those down, put them in memory, write them to disk, send them over the network. And there’s three official ways to do that.

First is the easy one. UTF-32, canonically called UCS-4 because, history. It’s pretty straightforward. Put your 21 bit number in a 32 bit integer. Done. OK, not quite done, because there’s little endian and big endian architectures, so when you send text to other systems, it needs to know the byte order. I’ll get to that in a moment, but what’s good and bad about this format.

It’s good because it’s simple. It’s easy to know where where the 100th code point will be in your file. It’ll start at the 400th byte. It makes your code point lookup tables pretty simple using basic bitwise operators. It’s nice.

So why not use it all the time? Well, it’s enormous. For basic Latin text, it’s 4 times larger than UTF-8. For the vast majority of text, it’s at least twice as large as other encodings. That really is the driving reason. There are some other weaknesses that I’ll discuss later, but it’s just too big to take seriously as a universal format.

But, you know, the most common Unicode code points have low numbers. That’s partially an accident of history, but it’s also kind of on purpose. So what if for most characters you just encoded the low two bytes. And then you add some marker that says, “this character is in the upper range and needs four four.” Well, that would be UTF-16. Two bytes for most characters, but sometimes it’s four.

That means for many languages, it’s pretty efficient, but for basic Latin it’s twice as big as it needs to be. You still have the big-endian, little-endian problem of UTF-32. And now you don’t know where the 100th code point is in a file any more. Because some characters are 2 bytes, but some are 4 bytes, you have to actually parse it from the beginning to figure out where any random offset actually is. If you just jump into a file, you could find yourself in the middle of character.

Both UTF-32 and UTF-16 also have a problem with streaming. If you pick up a stream of characters that’s already in progress, so you don’t know what the first byte was, you can’t in principle know where the next character boundary is. And if you start reading on the wrong byte, the whole file becomes gibberish. Now in practice, there are heuristic algorithms that can fix that, but the format itself doesn’t tell you where the character boundaries are.