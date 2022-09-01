---
layout: post
title: "One Little Corner of Unicode"
published: true
categories:
---

Humans like to write things down, and over the last several thousand years, we’ve developed a wide variety of ways to do that. And then, over the last century, we started building computers. And computers work with numbers, which does not line up well with how humans write things down. For decades, we developed numerous systems for encoding human writing into numbers so that computers could work with it.

In the 1980s and early 1990s, Unicode was developed to unify these systems so that there would be a single, consistent way to encode all the world’s writing systems, including the ability to include multiple writing systems in the same document. It includes rules for comparing and sorting, text direction, composing and decomposing characters, and on and on.

Unicode has made it practical for us to develop software that supports the native writings systems of the whole world.

But that is not the most important thing that Unicode has given us. No. The most important thing that Unicode has made possible is…

Emoji.

OK, that’s definitely not true. But it feels like. For years, I’ve been teaching people about bidirectional text and composing characters and normalized forms and why you can’t subscript Strings by an integer in Swift, and a common response is:

“Look, I don’t care about all these fancy writing systems. I just need English.”

And I ask? “And emoji?”

And they say “yeah, of course emoji. English and emoji.”

# 🤦🏻‍♂️

In my experience, emoji is the most complex writing system in the world. It is filled to the brim with weird grammar, special cases, and continual churn. It requires its own complex keyboards. If your code can support emoji on iOS, you get Chinese for free, and most other writing systems, too.

So let’s talk about Unicode.

The code point is the most basic unit of text in a computer encoding system. Ultimately, computers work with numbers, so we have to have a way to turn letters and symbols into numbers, and code points are how we do that. In Unicode, code points map a unique number to each “language thingy” for every human writing system.

What do I mean “language thingy?” Well. It’s complicated.

According to Unicode, code points map to “abstract characters.” What does that mean? The intention is that an abstract character is a fundamental unit of written language that’s independent of how it’s drawn.

# x́

In most Latin-using cultures, you’d recognize this as a ”lowercase x with an accent,“ even though it’s not a letter in any language I’ve ever heard of. That tells us that “lowercase x” and “with an accent” are probably abstract characters in our culture.

Now Unicode is wildly inconsistent about exactly how this idea is applied, and really there’s no universally consistent way you could apply it. Unicode is the way it is for many reasons. Backward compatibility with older systems, global politics, mistakes, and frankly, human writing systems are deeply messy, and so anything that tries to encode them is going to be deeply messy. But the idea is that there are these abstract pieces of human writing, independent of exactly how they’re drawn, that each code point represents.

# ❤️

Emoji is no different about this. They have code points, and they have a long history that make their code points inconsistent and messy. A lot of emoji pre-date Unicode and have naming and syntax that come from older systems.

For example, you want to show a red heart. Probably the most common color for hearts to be. So you search the official list of emoji for a red heart, and you don’t find one. There’s blue, white, yellow, beating, green, with ribbon, growing, broken, sparkling, black, and heavy black. There’s even rotated heavy black heart bullet. But where’s red? That seems weird.

### 💙🤍💛💓💚💝💗💔💖♥︎❤︎❥

First, many emoji come from phones that didn’t have color screens. So the words “white” and “black” don’t always mean the colors specifically, they sometimes mean outlined and filled. And “heavy” means “bold” or “thick.”

# ❤︎

So this is HEAVY BLACK HEART because it’s filled in and wider than BLACK HEART SUIT.
Some Unicode characters can be followed by a variation selector. This is used for things like distinguishing between Chinese-based characters that were merged by Unihan but need to round-trip to other encoding system where they’re distinct. But of course no one cares about that. We all use variation selectors for emoji. Every Unicode feature is eventually for emoji.

The two variation selectors used by emoji are 15 and 16. 15 is the “text version” of a character. And 16 is the “emoji version” of a character. So HEAVY BLACK HEART plus VS16 give us an emoji version of filled in, bold heart. Let me show you this in Swift.

```swift
let redHeart = "❤️"

print(redHeart.unicodeScalars.map { String(format: "%X", $0.value) })
// ["2764", "FE0F"]

"\u{2764}\u{FE0F}"
// "❤️"
```

Say I found this emoji I want to understand, so I copy and paste it into my Playground. To see what it’s made of, convert each unicodeScalar, unicode code point, to hex. And then to reconstruct it, use the backslash-u notation with the code point in curly braces. But what if you don’t know what FE0F means?

I use my favorite site for looking up characters. fileformat.info.

For emoji-specific information, I like emojipedia, but it only covers things related to emoji, while fileformat includes all Unicode.

This idea of combining code points to make a single character is extremely common in Unicode. Probably the most common example is the accented e in a word like resumé. There are two ways in Unicode to express that e. For somewhat historical reasons, it’s character U+00E9, LATIN SMALL LETTER E WITH ACUTE. But it can also be encoded as U+0065 LATIN SMALL LETTER E, followed by U+0301, COMBINING ACUTE ACCENT. These are both equally legitimate encodings. So when I want to search for the string ”resumé”, how does that work?

In Unicode there are standardized ways to compose and decompose characters, called Normalization forms. Swift handles these mostly for you.

```swift
let e = "e"             // U+0065 LATIN SMALL LETTER E
let acute = "\u{0301}"  // U+0301 COMBINING ACUTE ACCENT
let eAcute = "é"        // U+00E9 LATIN SMALL LETTER E WITH ACUTE

e + acute == eAcute     // => true
```

For example, these are equal in Swift. And the great thing is if you’re working in Swift, you can often ignore all these issues, which is why I’m not going to go into the details, but I want you to be aware of how they can create unintuitive results.

```swift
e.count             // 1
acute.count         // 1
(e + acute).count   // 1

var str = "e"       // "e"
str.append(acute)   // "é"
str.removeLast()
str                 // ""
```

For example, string lengths don’t always mean what you expect them to mean, and sometimes 1 + 1 is 1. And adding a character and then removing it may not do what you expect. And that’s because Swift’s idea of characters is pretty close to “thing that takes one unit of space on the line,” which is pretty close to what our intuition tends to be, but doesn’t map to Unicode code points in any consistent way. You have to be very careful when you start manipulating strings in terms of characters, particularly if you’re processing your data in chunks. It may not always do what you expect. You could split a character in half.

```swift
let girl = "👧"
let umlaut = "\u{0308}" // U+0308 COMBINING DIAERESIS
girl + umlaut
"X" + umlaut
"x" + umlaut
```

# 👧̈  Ẍ  ẍ

Emoji are characters, so you can apply diacritics like accents on them. But...it doesn’t usually work very well. While emoji are fairly standard Unicode characters, they’re not standard font glyphs. Normal characters are stored as vector graphics, and there are various metrics that the text layout system uses to place combining marks correctly, or at least reasonably. Notice how the umlaut is well-placed for both the capital and lowercase x, even though “x with an umlaut” is not something this font would have baked in like accented e. Emoji are stored in a font file as PNGs at various resolutions, and the text system doesn’t know where to put combining marks, so they get placed kind of randomly.
