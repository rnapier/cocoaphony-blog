---
layout: talk
title: "Bits and Bytes: Handling Raw Data"
talk_date: 2021-08-25
presentations:
  - conference: 360 iDev, 2021
    date: 2021-08-25
---
For many of us, “data” comes in the form of objects, or at least strings and numbers, maybe some JSON. But many problems require going deeper and dealing with raw bits and bytes, whether for encryption, audio and image processing, Bluetooth, networking, or just interoperating with other languages and systems. Sometimes we need to deal with the underlying representations of data.
This is a common source of confusion for developers who don’t deal with these issues often. This talk will provide the tools you need to work with data in many formats in ways that translate across languages. It’ll go into depth on data-to-string encodings like Base64, hex, URL-encoding, and PEM; string-to-data encodings like Latin-1, UTF-8, and Windows-1252; pure-data encodings like ASN.1 and DER; media encodings like WAV, JPEG, and PNG; and encoding containers like JWE, X.509, and AVI. It’ll also introduce useful unix and web tools for interpreting precisely what data you’re working with. Since data handling often involves cross-platform and cross-language issues, this talk will touch on the most common pitfalls and tools for handling raw data in JavaScript, Java/Kotlin, and Swift.
