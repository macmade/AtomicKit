AtomicKit
=========

[![Build Status](https://img.shields.io/travis/macmade/AtomicKit.svg?branch=master&style=flat)](https://travis-ci.org/macmade/AtomicKit)
[![Coverage Status](https://img.shields.io/coveralls/macmade/AtomicKit.svg?branch=master&style=flat)](https://coveralls.io/r/macmade/AtomicKit?branch=master)
[![Issues](http://img.shields.io/github/issues/macmade/AtomicKit.svg?style=flat)](https://github.com/macmade/AtomicKit/issues)
![Status](https://img.shields.io/badge/status-active-brightgreen.svg?style=flat)
![License](https://img.shields.io/badge/license-mit-brightgreen.svg?style=flat)
[![Contact](https://img.shields.io/badge/contact-@macmade-blue.svg?style=flat)](https://twitter.com/macmade)  
[![Donate-Patreon](https://img.shields.io/badge/donate-patreon-yellow.svg?style=flat)](https://patreon.com/macmade)
[![Donate-Gratipay](https://img.shields.io/badge/donate-gratipay-yellow.svg?style=flat)](https://www.gratipay.com/macmade)
[![Donate-Paypal](https://img.shields.io/badge/donate-paypal-yellow.svg?style=flat)](https://paypal.me/xslabs)

![AtomicKit](Assets/Icon.png "AtomicKit")

About
-----

**Concurrency made simple in Swift.**

**AtomicKit** is a Swift framework designed to ease dealing with concurrency in Swift projects.

### Background

Coming from Objective-C and C++, I lacked a few features in Swift, like Objective-C's  `@atomic` or C++'s  `std::atomic`.

Apple's GCD (Grand Central Dispatch) is absolutely awesome when it comes to synchronization, but you'll have to use it explicitely in Swift.  
Writing atomic/dispatched getters and setters is not a big deal, but it currently leads to a lot of boilerplate code, which I like to avoid in my projects.

The **AtomicKit** project intends to simplify this, by adding easy-to-use synchronization Swift types.

Synchronization Primitives
--------------------------

**AtomicKit** exposes a few synchronization primitive types, like:

 - **Mutex**
 - **RecursiveMutex**
 - **UnfairLock**

These types conforms to the `AtomicKit.Lockable` protocol, which extends `NSLocking`, meaning they all have the following methods:

```swift
public func lock()
public func unlock()
public func tryLock() -> Bool
```

### AtomicKit.Mutex

This is a wrapper for `pthread_mutex_t`.  
This version is **not recursive**.

### AtomicKit.RecursiveMutex

This is a wrapper for `pthread_mutex_t`.  
This version is **recursive**.

### AtomicKit.UnfairLock

This is a wrapper for `os_unfair_lock_t`.

Semaphores
----------

**AtomicKit** provides a `Semaphore` class.  
Semaphores are initialized with a count, and may be named, in which case they are shared between multiple processes.

The `Semaphore` class exposes the following methods:

```swift
public init( count: Int32 = 1, name: String? = nil )
public func wait()
public func signal()
public func tryWait() -> Bool
```

Internally, the `Semaphore` class uses `POSIX` semaphores for named semaphores, and `MACH` semaphores for unnamed semaphores.

Read-Write Locks
----------------

**AtomicKit** supports read-write locking mechanism using the `RWLock` class:

```swift
public enum Intent
{
    case reading
    case writing
}

public func lock( for intent: Intent )
public func unlock()
public func tryLock( for intent: Intent ) -> Bool
```

Atomic Properties
------------------------

**AtomicKit** provides a generic type called `Atomic`.  
If you're familiar with C++, you can think of it as `std::atomic`.

The goal is to provide a thread-safe property type that you can use in your own classes:

```swift
class Foo
{
    public var bar = Atomic< Bool >( value: false )
}
```

The example above declares an atomic `Boolean` property.  

Its value can be get with:

```swift
self.bar.get()
```

And can be set with:

```swift
self.bar.set( true )
```

Internally, `Atomic` uses an `UnfairLock`.

If more complex stuff is required with the value it holds, the `Atomic` generic type lets you execute a custom closure.

```swift
let foo = Atomic< String >( value: "hello" )

foo.execute{ ( value: String ) in value.append( ", world" ) }
```

You can also use a return value from the closure:

```swift
let isEmpty = foo.execute{ ( value: String ) -> Bool in value.isEmpty }
```

Atomicity is guaranteed in both cases.

### LockingValue

Under the hood, the `Atomic` class inherits from `LockingValue`.  
`LockingValue` works just the same, but takes an extra generic parameter specifying the type of lock used for synchronization.

As mentioned above, `Atomic` uses an `UnfairLock`.  
Using `LockingValue`, you can specify another type of locking mechanism, as long as it conforms to the `NSLocking` protocol:

```swift
let foo = LockingValue< String?, NSRecursiveLock >( value: nil )
```

Dispatched Atomic Properties
----------------------------

Using a locking mechanism is a way to achieve synchronization.  
But using **dispatch queues** also ensure synchronization between multiple concurrent accesses.

**AtomicKit** supports this through the `DispatchedValue` generic class.

A `DispatchedValue` is initialized with a default value, and with a dispatch queue:

```swift
let foo = DispatchedValue< String >( value: "", queue: DispatchQueue.main )
```

Then, every call to the `get` or `set` methods will be executed on the provided queue, thus achieving effective synchronization.

As the `Atomic` type, `DispatchedValue` also lets you execute custom closures, that will be executed on the provided queue:

```swift
let foo = DispatchedValue< String >( value: "hello", queue: DispatchQueue.main )

foo.execute{ ( value: String ) in value.append( ", world" ) }

let isEmpty = foo.execute{ ( value: String ) -> Bool in value.isEmpty }
```

### Dispatched properties and KVO

As it's a Swift generic type, the `DispatchedValue` class cannot be used from Objective-C, and so can't be used with KVO (key-value observing).

This might be a problem, especially if your project relies on Cocoa bindings, which use KVO.

**AtomicKit** solves this by exposing Objective-C and KVO compatible versions of `DispatchedValue`, specialized for common Objective-C types:

 - **DispatchedArrayController**
 - **DispatchedBool**
 - **DispatchedMutableArray**
 - **DispatchedMutableDictionary**
 - **DispatchedMutableSet**
 - **DispatchedNumber**
 - **DispatchedObject**
 - **DispatchedString**
 - **DispatchedTree**

All of these types defaults to the main dispatch queue, if none is provided.  
This is especially handy when using Cocoa bindings, as changes often needs to occur on the main thread, for UI reasons.

All of these specializations expose a `value` property, which is observable using KVO.  
It also means you can safely use Cocoa bindings with them.

License
-------

**AtomicKit** is released under the terms of the MIT license.

Repository Infos
----------------

    Owner:          Jean-David Gadina - XS-Labs
    Web:            www.xs-labs.com
    Blog:           www.noxeos.com
    Twitter:        @macmade
    GitHub:         github.com/macmade
    LinkedIn:       ch.linkedin.com/in/macmade/
    StackOverflow:  stackoverflow.com/users/182676/macmade
