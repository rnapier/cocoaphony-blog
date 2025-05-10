---
layout: post
title: "Wherefore, Tests?"
published: true
categories: testing
---

I'm going to talk about testing over the next few posts. If you've talked to me at any length over the last several years, you know I've been thinking about testing a lot, and I have somewhat unorthodox opinions. Unorthodox enough that I really haven't wanted to write them down because I'm really not trying to start an argument with anyone. If your approach to testing works for you and your team, I think you're doing it right and I don't think you should change just because I do it a different way.

But if you and your team struggle with testing and you think it's because you lack the discipline to "do things right," I'd like to offer another way of thinking about testing that has worked very well for many years over several teams and in multiple languages. In this series I'm going to focus specifically on iOS development working in Swift. Some topics are different in other environments. I might touch on those eventually, but to keep this already sprawling topic bounded, I'm going to stick to client-side Swift.

So none of this may apply to you. But if you feel that your current testing approach isn't working, I'd like to offer another option:

Mock as little as you can. Mock only at the edges. Minimize dependency injection. Test real code.

<!-- more -->

This is the point in the conversation at which many a good friend has, with great kindness, called me an idiot. And before I'm done, you may as well, and that's fine. If your mocks are working for you, you shouldn't abandon them. Maybe listen to some of my philosophical points, and ignore the rest. Or ignore it all. I'm warning you up front where this is headed.

But the best thing I've done for testing in multiple code bases has been to delete nearly all the mocks. In the process, I've also made production code better. I've spent the last few months removing mocks from my current project, while also improving test code coverage by tens of thousands of lines. Tests are simpler to write and they actually test things. It's possible to do a lot of testing with very little mocking.

In later posts, I'll explain how all of that actually works in code. Today, I want to focus on what the goal of testing even is.

## Why? Seriously. What are tests for?

I run into a lot of "testing for testing's sake" out there. Folks who get wrapped up in code coverage metrics and lose sight of why we're testing in the first place. I want to start with the most obvious, but least useful part of tests.

### Finding collateral bugs

This is the use case I think most people focus on. I make a change in the code, run the tests, and discover I broke something. It's an awesome feeling. The tests worked! It's also a terrible feeling. Why is my code so fragile that a change here breaks something over there? Or is that test failure just telling you the test hasn't been fixed yet because the spec changed? Yes, if you're a full TDD shop you would have changed the test first, and it would tell you the code is broken. But are you sure you've changed the test correctly? If you know you can always write the tests correctly, just write the code correctly.

I'm going to say this once. (I lie; I'm going to say it often.) TESTS ARE CODE. You will mess up your tests for exactly the same reasons you mess up your code. A test failure may mean a bug in the code. It may mean a bug in the test. It may mean bugs in both. It may be a misunderstanding about the spec and the tests and code are both reasonable, but different.

A failing test case is signal. It's useful. It's important. But by itself, it doesn't tell you a lot other than "you need to go look at this." I've worked with a lot of teams over the years and a lot of code bases with a lot of different testing disciplines. In every one of them, if someone made a change and some unexpected test failed, they would assume the tests are broken, not the code.