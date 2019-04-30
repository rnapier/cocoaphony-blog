---
layout: post
title: "Avoiding timing attacks on NSData"
date: 2014-01-24 13:48:22 -0500
comments: true
categories: 
---
Most comparison functions look something like this more or less:

```objc
BOOL compare(uint8_t *a, size_t aLen, uint8_t *b, size_t bLen) {
  if (aLen != bLen) {
    return NO;
  }

  for (size_t i = 0; i < aLen; ++i) {
    if (a[i] != b[i]) {
      return NO;
    }
  }
  return YES;
}
```

If the lengths are different, then they're not equal. Otherwise compare each element. If you find a mismatch, they're not equal. If at the end of the search, there were no mismatches, then they're equal. That's a fine comparison function. The same basic idea will work for for an `NSArray` or a `std::vector` or an `NSString`. The `std::equal` algorithm is basically the same (except for checking length equality).

Basic stuff. Very efficient. Also the source of a common security mistake: the timing attack. It looks like this:

```
- (BOOL)isAuthorizedWithKey:(NSData *)providedKey {
  return [providedKey isEqual:kSecretKeyData];
}
```

So simple. Who could imagine it's a problem? And in many cases (especially on iOS), it may not be exploitable. But let's see how an attacker can use this:

* Send the key 0x00 many times and keep track of how long it takes to fail.
* Send the key 0x00 0x00 many times and keep track of how long it takes to fail.
* Keep expanding the key by one byte.
* If the test function checks lengths, then the failure time will be slightly longer when your guess matches the length of the actual key. Now you know the length.
* Send the key (of the known length) containing just 0x00. Again, try it many times and track how long it takes to fail.
* Change the first byte to 0x01 and repeat.
* Continue changing the first byte until the failure takes slightly longer. Now you know the first byte.
* Repeat for the rest of the bytes.

While this requires a lot of tests, it will still be a tiny fraction of the number of tests required to brute force the whole keyspace. For example, even if you need 1,000,000 tests per guess to work out the average, the worst-case  will be: 

$$1,000,000 \times 256 \times length \ll 256^{length} \quad (length > 4)$$
