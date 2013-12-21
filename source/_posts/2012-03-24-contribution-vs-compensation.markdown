---
layout: post
status: publish
published: true
title: Some math behind "contribution != compensation"
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: There is a suggestion that the apparent gap between pay and productivity
  is due to some kind of inefficiency in the system, whether it be an inability to
  measure productivity or companies intentionally ignoring that value. I argue, based
  on economics
wordpress_id: 748
wordpress_url: http://robnapier.net/blog/?p=748
date: 2012-03-24 18:16:32.000000000 -04:00
categories:
- Software Development
tags: []
---
Thanks to @codinghorror, I recently read a blog post from Steve McConnell called <a href="http://blogs.construx.com/blogs/stevemcc/archive/2011/01/22/10x-productivity-myths-where-s-the-10x-difference-in-compensation.aspx">10x Productivity Myths: Where’s the 10x Difference in Compensation?</a> Steve quotes a question from Pete McBreen:

<blockquote>"One point in his article that McConnell did not address--<strong>programmer compensation does not vary accordingly.</strong> This is a telling point--if the difference is productivity can be 10X, why is it that salaries rarely fall outside the 2X range for experienced developers?" [emphasis in original]</blockquote>

He then provides some fairly satisfying answers. "The other guy is actually overpaid." "You're confusing coding with actual business value." "Companies pay the least they can get away with." etc. All his answers make good, intuitive sense. Unfortunately, despite being a longtime fan of Steve McConnell's work, I believe most are irrelevant or incorrect.
<a id="more"></a><a id="more-748"></a>

Let me state this a little more concretely. If a company pays Alice $X, but Alice generates $10X in marginal value, then there is a very strong incentive for another company to offer Alice $2X and receive $9X in marginal value. Alice would almost certainly accept $2X, and a competitor would be idiotic not to pay it. As long as Alice were free to change employers at will, and as long as employers were capable of determining Alice's value in even a vague way, this would naturally continue until there were little marginal value left (less than the friction of recruiting and moving and within the precision of determining Alice's productivity). That is to say, there should not be much money left on the table. In the normal version of this story, there is a massive amount of money on the table. It's hard to believe this continues indefinitely in a highly competitive, unregulated, and mobile industry like ours.

Arguing that it's impossible to measure Alice's productivity to any precision makes the entire discussion moot, since it eliminates the ability to say that Alice is 10x more productive. How did you decide that if productivity is unmeasurable? Even intuitive measurements would be sufficient to create a bidding war if there were really 10x value on the table.

It also seems unworkable that a company would continue to pay large numbers of people dramatically above their total contribution. Sure, here and there; large companies are quite inefficient in my experience. And at the executive level, I believe there is enough collusion between compensation committees and CEOs to make the system significantly inefficient. But almost any argument for this being systemic suggests that companies are highly altruistic. It's hard to believe that a greedy company would hold onto a significant number of low-level employees that would be cheaper to fire and replace with no one.

I suggest that there's another answer that doesn't require long-lived massive inefficiencies in the market. I suggest that Alice is being paid in another way and that our "loser" employee provides some other value. I'm further claiming that the value Loser provides is reasonably close to the money that Alice foregoes. In other words, Alice is paying Loser for his service, and thus a reasonably efficient economic system in equilibrium is restored. I'm not claiming to have created this idea. It's directly from R. H. Frank's <a href="http://www.jstor.org/stable/1805123">"Are Workers Paid their Marginal Products?"</a> where it is examined in detail in several industries, including ones where it is much easier to determine precise productivity than ours.

To see how this works, let's play it out in a system where productivity==pay. You have the option of two jobs, one with Company A and another with Company B. At Company A, you would be one of the most productive people there. In fact, you'd be twice as productive as the average employee. The average employee at A makes $50k (all numbers are total compensation).

Company B, on the other hand, has some of the most brilliant people in the industry. You'd be half as productive there as the average employee. Since the average employee at Company B is 4x as productive as the average employee at Company A, they also make 4x as much: $200k. So in either case, your "fair" compensation would be $100k. Which job do you choose?

Well, let's think about it some more. At Company A, you're going to be at the top of the pile. You're going to get the best assignments, designing the most cutting edge stuff that Company A does. That's going to be less cutting edge than Company B's most advanced stuff, but at Company B you're not going to work on the most advanced stuff. You're going to be at the bottom of the pile there, one of the most junior people. You're going to do maintenance on their legacy products. You're going to do the bug fixes that the senior guys don't want to do.

So you're faced with a very productive company where you're Loser or a less productive company where you're Alice. The question is, what kind of compensation would you require from each company in order to be willing to work there? Different people weigh these things differently. Some people would take a huge pay cut to do grunt work for a brilliant company (I know a guy who did this). But I'm guessing for most people Company B would have to pay them more to be at the bottom of the pile than Company A would to be at the top.

Now the math behind the pay compression should come into focus. If you demand $110k to work at Company B, you'd still be one of the lowest paid people there. But the average employee would only be paid 1.8x as much for 2x as much productivity. You just created the "unfair" situation we're talking about. On the other hand, if you choose to work on more exciting projects at Company A and are willing to do it for $90k, then you're on exactly the other side of the coin.

What this boils down to is that without Loser, Alice can't be at the top. Without someone to do the boring maintenance work, Alice would have to do it herself. So she willingly, if unconsciously, pays Loser a premium so she can work on cooler projects. Company B needs someone to do $100k junior work. You demand $110k to be junior there rather than $90k to be senior at Company A. So they pay Alice $10k less than her job is worth, you $10k more, and the system is back in balance. Except now you're Loser and Alice keeps asking why she doesn't make as much as her performance predicts.

This is not the only cause of what seem like unfair pay practices. There is absolutely a lot of inefficiencies in big companies that allow deadwood to coast. There are definitely politics that let do-nothings get to work on cool projects. In some cases Loser can make *more* than Alice for absurd reasons. But I'm arguing that these are the margins. If they were the primary cause, more efficient companies would destroy these idiotic firms by taking all their Alices. I'm saying that the core of the compression, the reason that 3x productivity can become 1.3x pay, is that it is the natural economic result of a free market working efficiently, and that Alice is paying Loser for her rank.

It may not be as satisfying an answer as "companies are messed up," but I think it actually explains the situation most accurately.

Footnote: Frank has recently put out a new, related book called _The Darwin Economy_. I'm not a fan of the book, even when I agree with it, because it glosses over some important points too easily. But for $10 you can read the <a href="http://www.jstor.org/stable/1805123">*American Economic Association*</a> paper and see some of the real-world studies that back up this particular economic theory.

I'll get back to writing about NEON assembly on the iPad in the next week or so.
