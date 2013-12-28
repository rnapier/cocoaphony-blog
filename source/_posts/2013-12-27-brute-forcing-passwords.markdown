---
layout: post
title: "Brute forcing passwords"
date: 2013-12-27 15:15:30 -0500
comments: true
categories: security
---
{% include mathjs %}

I got an [interesting question](https://github.com/rnapier/RNCryptor/issues/92)
recently:

>Assuming a password is not in a dictionary, what length is required to make a
>brute force attack infeasible?

That's a pretty good question, and we should be able to answer it fairly easily,
given a few assumptions.

To work this out, we really just need to know three things:

* How many passwords exist for a given length?
* How many passwords can we guess per time unit?
* How long a time unit do we consider "infeasible?"

The number of passwords for a given length depends on the number of different
characters we allow in a password. On common English keyboards, you can easily
type 26 lowercase, 26 uppercase, 10 numbers, about 32 symbols, and space. That's
95 different characters.[^tab]

[^tab]: I'm not including the tab key because it is very often not allowed in
passwords, especially on the web.

Then we can use some very fancy math[^not-fancy-math], where \\(\bf{S}\\) is the
number of characters we choose from (95 in this case).

[^not-fancy-math]: Not actually fancy math.

$$rate = \frac{S^{length}}{time}$$

$$S^{length} = rate * time$$

$$length = \log _S (rate * time)$$

$$length = \frac{\log(rate*time)}{\log(S)}$$

$$length \propto \frac{1}{\log(S)}$$

What's really interesting about this is that length of the password we need
grows inversely with the log of the size of our character set. That tells us
that password length is much important than the size of the character set. I'd
rather have a long password just from the lowercase letters than a short
password filled with letters and numbers and symbols. (More on that later.)

Now we need to figure out some useful numbers here. As I said, let's use 95 for
\\(\bf{S}\\). To work out the rate, we need to make some assumptions about the
kind of hardware we're facing. The longer "infeasible time" gets, the harder it
is to predict computation speeds. Let's use one "Early 2011 MacBook Pro" core as
the unit of computing power.[^ Why an "Early 2011 MacBook Pro" as the unit?
Because that's the computer  I happen to be sitting in front of.] We'll then
assume that we're facing an average of 10,000 units. That could be 1,250 "Early
2011 MacBook Pros" today, or it could be some smaller number of more powerful
machines in the future, or one core out of 10,000 machines that the attacker has
hijacked. But 10,000 cores is not an unreasonable working estimate for a
dedicated attacker to use against us.

How fast can one of my cores compute passwords for RNCryptor? We could write a
program to guess passwords by hand, but Common Crypto provides a tool to help us
out: [`CCCalibratePBKDF()`](http://www.opensource.apple.com/source/CommonCrypto/CommonCrypto-60049/include/CommonKeyDerivation.h). 
It will tell us how many rounds we need to achieve a certain delay. Remember,
the goal of PBKDF2 is to be slow, and to resist hardware optimizations.

``` objc
uint rounds = CCCalibratePBKDF(kCCPBKDF2,
                               8,   // Password length
                               8,   // Salt length
                               kCCPRFHmacAlgSHA1,
                               32,  // Key length
                               10); // Miliseconds
```

This returns between 9,000-10,000. To keep things simple, we'll say that one
"unit" can calculate 10,000 PBKDF2 rounds in 10ms. 10,000 PBKDF2 rounds is
exactly what RNCryptor uses to derive the passwors, so one unit can compute
about 100 RNCryptor passwords per second. So 10,000 units can guess 1 million
passwords per second.[^test-time]

[^test-time]: This doesn't include the time required to test the
resulting key. That's not a trivial consideration because of how RNCryptor
implements verification. Currently, the extra time to verify a password is
propotional to the length of the ciphertext. But I'm planning on adding a "fast
password verify" function in the v4 file format, so let's assume testing the key
is negligible.

There are (approximately) 3x10^7 seconds in a year. At one million (10^6) per
second, we can guess about 3x10^13 passwords per year. 95^7 is 7x10^13, so an 7
character password would take over a year to break by 10,000 cores. 95^8 is
about 6x10^15, so that's enough for 100 years. 95^9 is about 6x10^17, which
would be over 10,000 years, assuming 10,000 of our "standard" cores working on
it.[^average]

[^average]: On average, you should expect to find the key in half the total
time. 7 x 10^13 is roughly twice 3 x 10^13, so you should expect to find the
result in a year.

So to hold off 10,000 standard units for 100 years with RNCryptor takes an
8-character password, as long as we pick from all the easily typed keys on a
common English keyboard, and the attacker is purely brute forcing us.

[TODO:More about long passwords from small sets versus short passwords from large sets.]

