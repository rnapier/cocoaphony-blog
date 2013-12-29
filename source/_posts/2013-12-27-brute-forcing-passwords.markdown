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

The short answer is, using [RNCryptor](https://github.com/rnapier/RNCryptor) and
some reasonable security assumptions, it would be very difficult to brute-force
an 8 character password randomly taken from all the easily typable characters on
an English keyboard. The rest of this article will discuss my assumptions, and
how you would calculate good lengths for other assumptions.

<!-- more -->

To work this out, we really just need to know three things:

* How many passwords exist for a given length?
* How much effort (resources x time) does it take to test a password?
* How much attacker effort is "feasible?"

### How many passwords exist for a given length?

The number of passwords for a given length depends on the number of different
characters we allow in a password. On common English keyboards, you can easily
type 26 lowercase, 26 uppercase, 10 numbers, about 32 symbols, and space. That's
95 different characters.[^tab]

[^tab]: I'm not including the tab key because it is very often not allowed in passwords, especially on the web.

The number of passwords for a given set size (_S_) and a specific password
length (_n_) is _S^n_.

What's interesting about this function is how it reacts to changes in _S_ and
_n_. For example, let's consider a fixed password size (_n = 8_), with a
variable set size from _S = 26_ (lowercase English letters) to _S = 3000_
(roughly the number of everyday Chinese characters). Would we rather a long
lowercase English password or a short Chinese password?[^chinese]

[^chinese]: When discussing "characters" here, I mean actual characters. It doesn't matter how many bytes are used to represent them. So _XX_ and _谢谢_ are the same length for these purposes, no matter how they're encoded.

![Length vs. Set Size](/images/brute-forcing-passwords/length-vs-size.svg)

In this graph, we start at the same point (6 characters chosen from a set of
26). We then vary the length one character at a time (linearly) versus the set
size by orders of magnitude (exponetially). Increasing the length of the
password by two or three characters is better than increasing the number of
available characters 10-fold. So, given a choice, you'd rather have a long,
random password than anything else. This is the principle of AES key sizes. Each
bit is chosen from a set of just 2 "letters," but 256 bits still provides a huge
keyspace.

### How much effort (resources x time) does it take to test a password?

By design, most of the time required to test a password in RNCryptor is spent
converting the password into a key using
[PBKDF2](http://en.wikipedia.org/wiki/PBKDF2). PBKDF2 is is designed to be slow
specifically to make brute forcing difficult. RNCryptor uses 10,000 iterations
to convert the password into a key. How long that takes to calculate depends on
your machine, so we need to define some unit that we will measure our attack in.
Since I happen to have one in front of me, we're going to use "one core of an
Early 2011 MacBook Pro" as the unit.

There are a couple of things to keep in mind when choosing this unit. First, you
need to think in terms of what hardware your attacker is going to use against
you, not the hardware you used to encrypt. So think at least in terms of
desktops and servers, not iPhones. Second, remember that the proper unit is a
"core," not a system. PBKDF2 can't be computed in parallel, but the attacker can
easily spread many different PKBDF2 computations over as many cores as
available. That said, it doesn't really matter what the unit is; we just need a
way to describe attacker resources.

How long does it take one unit to test one password? With the current version of
the RNCryptor data format, it's dependent on the length of the ciphertext. But
the v4 data format will remove this overhead, so we'll assume almost all the
time is in the PBKDF2 iterations.

We could write a function to time this by hand, but Common Crypto provides 
[`CCCalibratePBKDF()`](http://www.opensource.apple.com/source/CommonCrypto/CommonCrypto-60049/include/CommonKeyDerivation.h)
to help us out. It will tell us how many rounds we need to achieve a certain
delay.[^calibrate]

``` objc
uint rounds = CCCalibratePBKDF(kCCPBKDF2,
                               8,   // Password length
                               8,   // Salt length
                               kCCPRFHmacAlgSHA1,
                               32,  // Key length
                               10); // Miliseconds
```

[^calibrate]: While `CCCalibratePBKDF` accepts a password length, the results are not very sensitive (if at all) to its value. The most important parameter is the delay.

This returns between 9,000-10,000 on my machine. To keep things simple, we'll
say that one "unit" can calculate 10,000 PBKDF2 rounds (one RNCryptor password)
in 10ms. Or alternatively, one unit can test approximately 100 passwords per
second.

### How much attacker effort is "feasible?"

Maybe by "feasible" we mean "in a few days on a laptop." Or maybe by "feasible"
we mean "within 100,000 core-years (10 years on 10,000 cores, or a month on one
million cores)." That isn't as shocking a scale as you might think. Some secrets
really do need to stay secret for decades, and 10,000 cores is small for a
botnet, several of which have several million active hosts with multiple cores
at any give time. You also have to consider technological advances. If the
secret you encrypt today is being attacked ten years from now, you have to scale
against those machines, not today's machines.

Eventually you have to decide on some number. For general purposes, I like to
use 100,000 core-years (with my "Early 2011 MacBook Pro" being the equivalent of
8 "cores"). If your secret has a fairly short shelf-life, you may be wiling to
go as low as 1,000 core-years, or for very sensitive information that needs
protection for decades, you may want to scale to 10 million core-years.

### Putting it all together

To recap our assumptions:

* 95 character set for passwords (_S_)
* 100 password tests per core-second, based on 10,000 PBKDF2 iterations (_rate_)
* 100,000 core-years of effort = 100,000 x (3 x 10^7) core-seconds (_effort_)

Now it's just some fancy math[^fancy-math] to solve for _length_ (which must be
integral):

[^fancy-math]: Not actually fancy math.

$$\newcommand{\unit}[1]{\mathrm{#1}}$$
$$rate = \frac{S^{length}}{effort}$$

$$S^{length} = rate \times effort$$

$$length = \left\lceil\log _S (rate \times effort)\right\rceil$$

$$length = \left\lceil\frac{\log(rate \times effort)}{\log(S)}\right\rceil$$

$$length = \left\lceil\frac{\log(100 \times (100,000 \times 3 \times 10^{7}))}{\log(95)}\right\rceil$$

$$length = 8$$

The careful reader may be asking "shouldn't the attacker expect to find the
password in half this time?" You're completely correct. Since the correct
password is as likely to be in the first half searched as the last half, the
expected time is technically half as long. But it doesn't matter. Because
password length grows logithmically, halving or doubling the effort has little
impact. You'll still get 8 characters.

To get up to 10 million core-years (two more orders of magnitude), just pushes
us up to 9 characters. That shouldn't be surprising, since there are almost 100
characters in our set, every time we add another character to the password we
should expect to add two orders of magnitude to the difficulty.

What if the password were still random, but only selected from lowercase letters
and numbers? Then we need 10 characters to get 100,000 core-years of effort. So
smaller character spaces increase the password length needs, but not by a lot.

### What are the take-aways?

* Between 8 and 10 random characters is a quite good password. Even with a much
  smaller number of iterations of PBKDF2, 10 character random passwords hold up
  well.

* This analysis only applies when the attacker is brute-forcing the password 
  space. Most attackers do not do it this way. They more often attack poorly
  chosen or reused passwords.

* PBKDF2 is critical for slowing down brute-force attacks. PBKDF2 adds several
  orders of magntiude to the attacker's effort.

* When thinking about spaces, orders of magnitude are more important than actual
  values. If you're not adding an extra zero, you're not making much impact. Try
  to have at least a couple of orders of magnitude safety margin against the
  resources you think the attacker will ever have over your time horizon.