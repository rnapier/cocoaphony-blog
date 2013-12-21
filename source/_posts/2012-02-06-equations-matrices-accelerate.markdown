---
layout: post
status: publish
published: true
title: Converting algebra to matrices for Accelerate framework
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: In this post, you will learn the basic math and tools required to convert
  algebraic equations into the kind of matrices required to use the Accelerate framework.
wordpress_id: 607
wordpress_url: http://robnapier.net/blog/?p=607
date: 2012-02-06 11:19:28.000000000 -05:00
categories:
- cocoa
tags: []
---
<div><!-- turn off markdown -->
[latexpage]
<p>Chapter 18 of <a href="http:/book">iOS:PTL</a> includes code for calculating points on a Bézier curve (see CurvyText in the <a href="/bookcode">sample code</a>). In the book, I hinted that this operation would likely be well suited to the <a href="https://developer.apple.com/performance/accelerateframework.html">Accelerate framework</a>. The Accelerate framework provides hardware-accelerated vector operations. Solving Bézier equations seems a perfect fit. I'll get more into Accelerate in later posts (including some thoughts on when to use it), but first I need to introduce some mathematical groundwork.</p>

<p>In this post, I'm targeting a specific kind of developer; one like myself. My mathematically inclined friends will find this so trivial that it's hardly worth discussing. For those of you who have never seen a matrix before, this may be a bit dense. But if you're like me, and once upon a time you actually took linear algebra, but today you wouldn't know a transpose if it invited you to dinner, this may help. (The last time I computed a dot-product, the Newton hadn't been released…) My goal isn't to teach you Guassian elimination or eigenvalues. My goal is to show you by example the specific tools you need to convert the math you find in a book into matrices so you can calculate it faster. (And how to cheat with the incredible new tools available to us.)</p>
<!-- more -->

<p>So by way of example, we will consider the cubic Bézier curve (as expressed by <a href="http://en.wikipedia.org/wiki/Bézier_curve#Cubic_B.C3.A9zier_curves">Wikipedia</a>):</p>

[latex]
\begin{equation}
\mathbf{B}(t) = (1-t)^3\mathbf{P}_0 + 3(1-t)^2\mathbf{P}_1 + 3(1-t)t^2\mathbf{P}_2 + t^3\mathbf{P}_3, t \in [0,1].
\end{equation}
[/latex]
<p>This means that for each coordinate (x,y), you calculate the above for values running from t=0 to t=1. In C that translates into:</p>

<code><pre>
static CGFloat Bezier(CGFloat t, CGFloat P0, CGFloat P1, CGFloat P2,
   	              CGFloat P3) {
  return 
    powf(1-t, 3) * P0
    + 3 * powf(1-t, 2) * t * P1
    + 3 * (1-t) * powf(t, 2) * P2
    + powf(t, 3) * P3;
}
</pre></code>

<p>For the four control points (<code>P0</code>...<code>P3</code>), you pass the <code>x</code> value to <code>Bezier()</code> and get back the <code>x</code> value of the curve. Repeat for <code>y</code>. There are many reasons that the above approach is inefficient. We'll discuss that more in later posts. But for this post, the goal is to figure out how to convert this into an matrix operation so we can use some of of our fancy hardware to calculate it for us.</p>

<p>The first step is realizing what kind of matrix we want. Our goal is to collect all the <code>t</code> terms into one matrix, all the <code>P</code> terms into one matrix. and all the constants into a third matrix. When we're done, it'll look like this (where <code>K</code> is the constants):</p>

\begin{equation}
\mathbf{B}(t) = \mathbf{PKT}
\end{equation}

<p>Written out, that looks like:</p>

\begin{equation}
\mathbf{B}(t) = \begin{pmatrix}
\mathbf{P}_0 & \mathbf{P}_1 & \mathbf{P}_2 & \mathbf{P}_3 
\end{pmatrix}
\begin{pmatrix}
??? \\ 
the\ constants \\
??? 
\end{pmatrix}
\begin{pmatrix}
t^3 \\
t^2 \\
t \\
1
\end{pmatrix}
\end{equation}

<p>The four <code>P</code> values are the control points from the Bézier equation (these are points, so they include an x and y). The four <code>t</code> terms are the powers that occur in the equation (remember: 1 = t<sup>0 </sup>).</p>

<p>When you multiply matrices, the result has the number of rows in the first matrix and the number of columns in the second. So <code>P</code> is 1x4 and the constants are MxN (we'll figure out M and N shortly). So that result is 1xN. Times <code>T</code> (4x1) and we'll finish up with a 1x1 matrix. A single point value. This is why it matters that <code>P</code> is in a row and <code>T</code> is in a column.</p>

<p>But a "point" is a vector. Let's make that a little clearer (I hope):</p>

\begin{equation}
\begin{pmatrix}
B_x(t)\\
B_y(t)
\end{pmatrix}
 = \begin{pmatrix}
\mathbf{P}_0 & \mathbf{P}_1 & \mathbf{P}_2 & \mathbf{P}_3 
\end{pmatrix}
\begin{pmatrix}
???\\
the\ constants\\
???\\
\end{pmatrix}
\begin{pmatrix}
t^3 \\
t^2 \\
t \\
1
\end{pmatrix}
\end{equation}

<p>OK, that's a little closer to a <code>CGPoint</code>. One x, one y. But what about "the constants?" These are the multipliers for each of the terms in "expanded form." What we want is our equation in a form like:</p>

\begin{equation}
aP_0t^3 + bP_0t^2 + cP_0t + dP_0 + eP_1t^3 + fP_1t^2 + gP_1t + \cdots
\end{equation}

<p>This gives us the sum of every combination of each <code>P</code> with each power of <code>t</code>. When you see "the sum of every combination" you should be thinking dot product and matrix multiplication. From this equation, it shouldn't take a lot of imagination to figure out what <code>K</code> looks like.</p>

\begin{equation}
\begin{pmatrix}
B_x(t)\\
B_y(t)
\end{pmatrix}
 = \begin{pmatrix}
\mathbf{P}_0 & \mathbf{P}_1 & \mathbf{P}_2 & \mathbf{P}_3 
\end{pmatrix}
\begin{pmatrix}
a & b & c & d \\
e & f & g & h \\
i & j & k & l \\
m & n & o & p
\end{pmatrix}
\begin{pmatrix}
t^3 \\
t^2 \\
t \\
1
\end{pmatrix}
\end{equation}

<p>Now, if only we had a way to figure out all those constants easily. We could do it with pencil and paper, but I always screw up simple algebra. If only there were some device that did mechanical operations really well. Just imagine if someone put up a <a href="http://www.wolframalpha.com/">free web service</a> that would do algebra for you.</p>

<p>Bless you Wolfram. You are my hero.</p>

<p>So we head over to Wolfram|Alpha and ask it to <a href="http://www.wolframalpha.com/input/?i=expand+%281-t%29%5E3+P_0+%2B+3+%281-t%29%5E2+t+P_1+%2B+3+%281-t%29+t%5E2+P_2+%2B+t%5E3+P_3">expand the Bézier equation</a> for us:</p>

<code><pre>
expand (1-t)^3 P_0 + 3 (1-t)^2 t P_1 + 3 (1-t) t^2 P_2 + t^3 P_3
</pre></code>

<p><img style="display:block; margin-left:auto; margin-right:auto;" src="http://robnapier.net/blog/wp-content/uploads/2012/02/wolframalpha-20120206103919629.gif" alt="wolframalpha-20120206103919629.gif" border="0" width="590" height="123" /></p>

<p>And from that, we can work out our matrix:</p>

\begin{equation}
\begin{pmatrix}
-1 & 3 & -3 & 1\\
3 & -6 & 3 & 0 \\
-3 & 3 & 0 & 0 \\
1 & 0 & 0 & 0
\end{pmatrix}
\end{equation}

<p>Now, in fairness, I have found this matrix several <a href="http://www.google.com/search?client=safari&rls=en&q=bezier+matrix&ie=UTF-8&oe=UTF-8">places on the internet</a>. So why bother doing all this? Why not just copy the final answer? For the Bézier calculations I wanted to do, I also need the first derivative of this, and I couldn't find the matrix for that anywhere. So sometimes the answer isn't just out there for you. And from experience, let me say that trying to debug this kind of code when you don't actually know what the matrix means is... challenging.</p>

<p>As an exercise, calculate the matrix for the Bézier derivative yourself. Wolfram|Alpha will give you the derivative of a function using the command <code>derivative</code> (instead of <code>expand</code>). I'll give you a hint: the matrix is not 4x4. I'll post the answer (and how to get it) in my next installment.</p>
</div>
