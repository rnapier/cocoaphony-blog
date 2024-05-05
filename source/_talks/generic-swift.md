---
layout: talk
title: "Generic Swift: It Isn't Supposed to Hurt"
repo: https://github.com/rnapier/generics
talk_date: 2019-04-17
presentations:
  - conference: FrenchKit 2019
    date: 2019-10-07
    conference_link: https://frenchkit.fr
    video: https://youtu.be/RvSoXVxN7Aw
    notes: also a 90 minute masterclass
  - conference: SwiftFest 2019
    date: 2019-07-29
    conference_link: https://swiftfest.io/schedule/#session-020
  - conference: AltConf 2019
    date: 2019-07-05
    video: https://youtu.be/DXwJg0QTlZE
  - conference: 360iDev 2019
    date: 2019-08-25
    notes: 4 hour workshop
  - conference: PhillyETE 2019
    date: 2019-04-23
    conference_link: https://2019.phillyemergingtech.com
    video: https://youtu.be/_m6DxTEisR8
    highlight: true
  - conference: Swift by Midwest, 2019
    date: 2019-04-17
---
They said Swift is “protocol oriented,” so you wrote protocols. But you wanted
them to be generic, so you added associated types. But your collections broke,
so you added type-erasers. But your “as”-casts broke, so you switched to Any.
But then everything broke, so you read about Mirror. And the tears began. Why
did it have to be so hard to make an array?

It doesn’t have to be so hard. But it’s very easy to use the wrong tools to
solve the wrong problems. In this session I’ll help you reevaluate what it
means to write generic Swift and how to choose the right tools for the job.
Whether your goal is reusable view controllers, flexible networking,
data-driven UI, effective unit testing, or just the joy of elegant data
structures, you’ll learn how to work with Swift and not fight the compiler.

This talk assumes familiarity with Swift syntax for generics, protocols,
extensions, enums, and first-class functions (such as completion handlers), as
well as the basic differences between Swift structs and classes. More advanced
topics, including protocols with associated types, enums with associated data,
closures, and functions as return types, will be introduced and explained.
