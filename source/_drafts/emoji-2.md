---
layout: post
title: "Just One Piece of Unicode"
published: true
categories:
---




# Z̤͑̈́͢ͅâ̭ͭ͝l͔̑̾̐͏͓͓̯̝ͧ̿͋go̧̗͙̳͗ͩ͐͘͜!̹

As long as we’re talking about combining characters, I might as well take a brief detour into a fun way to abuse them. Zalgo text. If you’ve ever seen this kind of weird “corrupted” text before, it’s just using Unicode.

```swift
func zalgo(_ text: String) -> String {
    let combining = (0x0300...0x036f)   // The main block of combining characters
        .compactMap(UnicodeScalar.init) // Converted to Characters
        .map(Character.init)

    // For each character
    return text.map { char in
        // Pick a random number of characters to add
        let zalgoChars = (0..<Int.random(in: 0...15))
            .map { _ in combining.randomElement()! }
        return String(char) + String(zalgoChars)
    }.joined()
}
```

There are a lot of possible combining characters in Unicode, but there’s a large block of them that work well and are supported on most platforms in the 0300 page. So for each character in the original text, you pick between zero and 15 combining characters, and add them between each character. But what if we want to de-zalgo this text? Remove all the combing characters. Of course we could just look for characters in the 0x0300 range, but we can also ask Swift for information about each character.

```
func dezalgo(_ text: String) -> String {
    // For each character in the string
    text.map { char in
        // Make a new String
        String(
            // By filtering the code points
            char.unicodeScalars.filter { scalar in
                // To ones that are base graphemes
                scalar.properties.isGraphemeBase
        })
    }.joined()
}

dezalgo(zalgo("Zalgo!"))    // Zalgo!
```

In Swift, a String is made of Characters. And a Character is made of code points, or Unicode Scalars. Each Unicode Scalar, each code point, has a lot of information about what kind of thing it represents. You can get that by checking its properties. There’s tons of these. You can check if it its a letter or a number or emoji, or marks the end of a sentence. You can even find out its numeric value for things like the 1/5 fraction or 4 in a circle. Most of the time you probably want to use methods on Character rather than diving all the way down into the UnicodeScalar properties, but sometimes it’s useful for filtering out things like this.

Emoji have their own systems of combining to form a single character. I’ve already shown how variation selectors work, but there are a lot more.

# 1⃣ 1⃣️

For example, you can put a box around numbers by adding COMBINING ENCLOSING KEYCAP. But you can also give them an emoji appearance by adding the emoji variation, 16.

```swift
let keycap = "\u{20E3}" // U+20E3 COMBINING ENCLOSING KEYCAP
"1" + keycap

let var16 = "\u{FE0F}"  // U+FE0F VARIATION SELECTOR-16
"1" + keycap + var16
```

# Flags

Flags are composed of two regional letters. These aren’t normal letters, they’re code points specifically for this purpose. They match ISO region codes.

```swift
let regionU = "\u{1F1FA}"   // 🇺
let regionS = "\u{1F1F8}"   // 🇸
let regionD = "\u{1F1E9}"   // 🇩
let regionE = "\u{1F1EA}"   // 🇪
let regionN = "\u{1F1F3}"   // 🇳

regionU + regionS   // 🇺🇸
regionD + regionE   // 🇩🇪
regionU + regionN   // 🇺🇳
regionE + regionU   // 🇪🇺
regionN + regionN   // 🇳🇳
```

>“Some region sequences represent countries (as recognized by the United Nations, for example); others represent territories that are associated with a country. Such territories may have flags of their own, or may use the flag of the country with which they are associated. Depictions of images for flags may be subject to constraints by the administration of that region.” (Unicode Technical Standard #51, Unicode Emoji. Annex B: “Valid Emoji Flag Sequences.”)

The spec would make clear is not a statement of whether something is or is not a country. Some are territories, some disputed territories, and the ISO committee would really like to stay out of global politics about it. That of course is impossible. But bless their hearts, they try.

There are two macro-regions, the UN and EU, but they act just like regular regions, so it’s not a big difference.
If the letters don’t form a known region, then they’re displayed in these dashed boxes. Sometimes people want to use these characters for the dashed box effect itself, but of course that’s tricky, because it might form an identifier.

```swift
let zwsp = "\u{200B}"
regionU + zwsp + regionS    // 🇺​🇸
```

Now I’d never tell you to abuse characters for things they weren’t intended for, and the region characters are for regions, not for fancy display purposes. But it happens to be true that you can put zero-width white space between them, and that is a general tool for avoiding character combinations that you don’t want.

# Emoji Tag Sequence

```swift
let blackFlag = "\u{1F3F4}" // 🏴
let tag_g = "\u{E0067}"
let tag_b = "\u{E0062}"
let tag_s = "\u{E0073}"
let tag_c = "\u{E0063}"
let tag_t = "\u{E0074}"
let tag_cancel = "\u{E007F}"

blackFlag + tag_g + tag_b + tag_s + tag_c + tag_t + tag_cancel  // 🏴󠁧󠁢󠁳󠁣󠁴󠁿
```

For regional subdivisions like states, there’s a completely different system, which is tags. Tags are a general purpose tool for modifying emoji, but this is the only thing they’re currently used for. You start with an emoji, in this case a black flag, it must be black, and then you spell out the tag using the tag letters, again these are not normal letters, they’re specifically for tags, and you terminate the string with a tag cancel. For regional subdivisions, the tags are lowercase tag letters that start with the region identifier, followed by the subregion identifier. So for example, the California flag would be u, s, c, a, cancel. But that won’t work on most platforms today. The current recommendation only includes subdivisions for Great Britain. So there are flags for English, Scotland, and Wales, and that’s it.

I do kind of expect the recommendation to expand to include more regions, particularly the states in the US, but we’ll see. You’ll notice that tag letters are invisible, and if the tag is unrecognized, it’ll generally just display a black flag. The recommendations suggest adding a little question mark to the flag to make it clear that the tag wasn’t understood, but Apple doesn’t do that currently.

And of course no discussion of flags would be complete without the pirate flag and the rainbow flag. And this year the recommendation added the transgender flag, but Apple doesn’t support it quite yet. I expect soon.

```swift
let whiteFlag = "\u{1F3F3}"     // 🏳
let scullAndBones = "\u{2620}"  // ☠
let rainbow = "\u{1F308}"       // 🌈
let transgender = "\u{26A7}"    // ⚧
blackFlag + zwj + scullAndBones + var16 // 🏴‍☠️
whiteFlag + var16 + zwj + rainbow       // 🏳️‍🌈
whiteFlag + var16 + zwj + transgender   // (coming soon)
```

# Not all flags wave

Note that the white and black flags here are the WAVING WHITE FLAG and WAVING BLACK FLAG. Not to be confused with WHITE FLAG (U+2690) and BLACK FLAG (U+2691), which won’t work for these uses. And unfortunately, if you use the “Show Emoji and Symbols” pane on your Mac, and search for “black flag,” you’ll get the wrong one.
The other problem is, if you read the spec, it says “black flag,” not “waving black flag.” Why?

```swift
"\u{2691}"  // ⚑  "BLACK FLAG"
"\u{1F3F4}" // 🏴 "WAVING BLACK FLAG"

Emoji are usually described in terms of Common Language Data Repository (CLDR) short names, which are generally lowercase, rather than all caps Unicode names. The Unicode names are unique, immutable identifiers, and sometimes are quite long. The CLDR short names are not promised to be unique, can change over time, and can be localized. Most of the time it’s not a big deal. The two are usually pretty close in English, but not always, and sometimes it’s a little ambiguous like black flag versus WAVING BLACK FLAG.

```