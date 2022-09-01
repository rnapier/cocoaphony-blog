I sometimes see questions along these lines:

T: I have an Optional that I *know* exists. What should I do?
M: !
T: But that might crash.
M: Only if it doesn't exist. You said you *know* it does.
T: I do, but what it doesn't?
M: That's not what "know" means.


`!` is an assertion that you know something the compiler can't prove. Collection subscripts are the same thing. You're saying you're certain this index will exist, even though the compiler can't prove it.

I find folks who are very comfortable writing `xs[0]`, but uncomfortable writing `xs.first!`.

That's syntax clouding our thinking.

The scary thing isn't !. The scary thing is code based on unproven assertions.

If you can prove something exists, but the compiler can't, first rethink your code. You may be using too many Optionals (many people do). A really common cause is parsing JSON. Just because it's Optional in the JSON doesn't mean it should be Optional in your struct.

If you're using `??` a lot, you almost certainly have a "non-Optional Optional." Assign that default value when you create the struct. Sometimes that means you'll need a custom Decodable, or you'll need to split your JSON Decodable from the struct you use in the rest of the app.