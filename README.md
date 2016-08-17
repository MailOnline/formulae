[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift 3.0 ß5](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](https://developer.apple.com/swift/)

**Note:** The lib is currently in flux, so I would advise against using it. 

### Intro

formulae in a nutshell is able to generate observables (`Property<T>` and `MutableProperty<T>`) from a string. It does so in two steps:

1. Generates a [reverse polish notation](https://en.wikipedia.org/wiki/Reverse_Polish_notation) representation from an input string via Dijkstra's [Shunting-yard algorithm] (https://en.wikipedia.org/wiki/Shunting-yard_algorithm). Something like `5 + X`, in our intermediate representation, would look like this: `[.constant(5), .variable("X"), .mathSymbol(.mathOperator(.plus)]`
2. We then transform the `.variable`s into actual [observable properties](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/ReactiveCocoa/Swift/Property.swift). Internally, it uses memoization to achieve this, since we need to cache each newly created property and use it when an operation is about to be used. If we didn't cache each property, it would be impossible to chain and create dependencies between them (for example with `y = x + 5` the variable `y` depends on `x`)

This approaches opens the door to dynamic UI's that rely in mathematical formulas in a simple and expressive way.

### Example

 Imagine a scenario where we have two sliders and a label that represents the product of both sliders values. 

Let's start by creating the formula:

```swift
let z = "x * y"
```

`x` and `y` are what we would like to change with our sliders.  `z` is what we would like to observe and eventually update the label with. It's important to notice that a formula (in this case `z`) is a read only property (`Property<T>`) while `x` and `y` are read/write (`MutableProperty<T>`). 

The first step is to create tokens from it:

```swift
let xT = "x".tokenized()
let yT = "y".tokenized()
let zT = "x * y".tokenized()
```
We then map each representation to its variable:

```swift
let variables = ["x" : xT, "y" : yT,  "z" : zT]
```

We then create a function that will generate an observable token for each variable (`x`, `y` and `z`):

```swift
let f = createObservableTokens(variableToTokens: variables)
```
Finally we apply this function `f` to each array of tokens:

```swift
 let propertyX = tokensX.reduce([], f).first // .readWrite(let mutablePropertyX)
 let propertyY = tokensY.reduce([], f).first // .readWrite(let mutablePropertyY)
 let propertyZ = tokensZ.reduce([], f).first // .readOnly(let propertyZ)
```

The output will be a chain of properties that respect what we described: `z = x * y`. 

```swift
propertyZ.producer.startWithNext {
	print($0) 
}
                    //   z.value == 0 ( 0 * 0)
propertyX.value = 1 //   z.value == 0 ( 1 * 0)
propertyY.value = 1 //   z.value == 1 ( 1 * 1)
propertyY.value = 3 //   z.value == 3 ( 1 * 3)
propertyX.value = 2 //   z.value == 6 ( 2 * 3)	
```

## License
Reactor is licensed under the MIT License, Version 2.0. [View the license file](LICENSE)

Copyright (c) 2016 MailOnline
