---
layout: post
status: publish
published: true
title: Core Data vs. RDBMS
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: "For those of you familiar with SQL and coming to Core Data, you probably
  want to separate the concept of \"database\" into the two kinds we're discussing
  here. There are relational databases, which is what you're probably used to, and
  object databases, which is what Core Data provides. Core Data happens to implement
  its object database on top of a relational database (SQLite), but that is a opaque
  implementation detail.\r\n\r\nIn a relational database, the key actions are the
  select and the transaction. In the select, you ask the database to form itself into
  a collection of columns (joins are just a fancy way of doing that), filter and sort
  itself according to some set of rules, and then return you a linear collection of
  rows. In the transaction, you inform the system that you are beginning a transaction,
  instruct the database to perform a series of transformations, and then commit or
  roll-back the transaction. It's a great model, but Core Data doesn't look much like
  it."
wordpress_id: 11
wordpress_url: http://cocoaphony.wordpress.com/?p=11
date: 2009-03-05 11:16:25.000000000 -05:00
categories:
- cocoa
tags:
- cocoa
- Core Data
---
For those of you familiar with SQL and coming to Core Data, you probably want to separate the concept of "database" into the two kinds we're discussing here. There are relational databases, which is what you're probably used to, and object databases, which is what Core Data provides. Core Data happens to implement its object database on top of a relational database (SQLite), but that is a opaque implementation detail.

In a relational database, the key actions are the select and the transaction. In the select, you ask the database to form itself into a collection of columns (joins are just a fancy way of doing that), filter and sort itself according to some set of rules, and then return you a linear collection of rows. In the transaction, you inform the system that you are beginning a transaction, instruct the database to perform a series of transformations, and then commit or roll-back the transaction. It's a great model, but Core Data doesn't look much like it.<!-- more -->

Core Data provides an object database, which can be thought of as a fancy implementation detail behind an object graph. If your data set is small enough, most everything you can do with Core Data can be done just by creating an object model in memory and saving it out with NSDictionary -writeToFile:atomically: (plus some tedious, but straightforward, code to tie to the UI without bindings). And in fact, that is how I often do it. But what if you have a very large dataset such that reading it all into memory is not efficent enough? Core Data, and specifically NSManagedObject, comes to help. Its primary function is to make the process of faulting transparent. "Faulting" is when you bring something into memory at the point that it's needed, much like a virtual memory system. And in fact, much of Core Data can be thought of as a virtual memory system for data. Like a VM system, it gives you the illusion that all of your data is available at the same time.

Core Data's other feature, which really is quite separate, is that it is bindings-compatible. So you can wire up UI elements to NSArrayControllers that are tied to Core Data element classes, and it all just "magically works." And when you tie an NSArrayController to an NSTableView, it suddenly feels like you've got a relational database again, but you don't. What you have is a slice of an object graph that is being accessed as an ordered collection (i.e. an NSArray). The object graph exists independently of that. It's just a sea of objects that have pointers to each other. There are no "rows" except when an NSArrayController points to a bunch of objects and provides an order for them. And if another NSArrayController points to those same objects, they can have different orders at the same time. But within the NSManagedObjectContext cloud, they're all just objects, hanging out, pointing to each other.

So all of this is a very long way of saying that the goal of Core Data is to make the world look like you just have a big object graph. That's very freeing. In theory, you don't need to worry about data normalization or problems like that. In practice you still need to worry about good data design, because that's always important, but you don't need to worry as much about the underlying impementation details as in a SQL database.

So what I tend to do is start out in the Model Designer and start sketching out my object relationships. Even if you go back and hand-implement them, it's a good place to lay out your data design. In theory, you shouldn't need to be worrying about foreign keys or anything like that. Just relationships from one object to another. Just as if it were all going to be stored in memory as a massive data structure.

So let's take an example of how the thought processes are different. Think of a Department. In RDBMS-land, you would assign a "Department" key to a bunch of Employee objects. You would then SELECT for Employees who had a matching Department key, and you'd wind up with an array-like structure that you would then display.

In CoreData it's a bit different. You would actually create a Department object. It would have an -employees property. Each Employee would also have a -department property, and these two properties are symmetric. Now yes, deep down in the SQLite there is a unique key that's tying these folks together, but that's not really your problem. So most of the time, you don't SELECT across the entire database asking every Employee "what's your department key?" You ask the Department "who are your Employees?" And it knows because it has pointers to the actual objects, not their IDs.

Your display code is then completely stupid about what data is really out there. You hand it the Department, and tell it to ask for -employees. For each Employee it returns, ask for -firstName and put it in this column. Then ask for -lastName and put it in this column. And this is why Core Data ties in perfectly with things like NSTableView. It's all just objects asking other objects about stuff.
