---
layout: talk
title: "Advanced Codable: When the API wasn’t built for Swift"
talk_date: 2022-08-29
presentations:
  - conference: 360 iDev, 2022
    date: 2022-08-29
---
Codable is an incredible part of Swift, and auto-generated conformances make many jobs trivial. But some server APIs are more complicated than the basic configuration options can handle, and you’ll need to write your own conformances. You might even have to write your own top-level encoder or decoder. In this session, I’ll cover hand-written solutions to common Codable problems such as dynamic keys, flattening nested and complex structures, and converting between ordered and unordered collections.

I’ll provide tips for avoiding custom implementations when they aren’t needed, but for when that isn’t enough, I’ll dive deeper into the details of how Codable works, what it can and can’t do, and how to practically build your own solutions from scratch when you must. JSON is a much more flexible format than JSONDecoder can support. If you need to parse JSON with ordered keys, duplicate keys, arbitrary-precision numbers, or meaningful nulls, this is the talk for you.
