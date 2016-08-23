[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift 3.0 ß5](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](https://developer.apple.com/swift/)

**Note:** The lib is currently in flux, so I would advise against using it. 

### Intro

*formulae* in a nutshell is able to generate observables (`Property<T>` and `MutableProperty<T>`) from a string. It does so in two steps:

1. Generates a [reverse polish notation](https://en.wikipedia.org/wiki/Reverse_Polish_notation) representation from an input string via Dijkstra's [Shunting-yard algorithm] (https://en.wikipedia.org/wiki/Shunting-yard_algorithm). Something like `5 + x`, in our intermediate representation, would look like this: `[.constant(5), .variable("x"), .mathSymbol(.mathOperator(.plus)]`
2. It then transform the `.variable`s into actual [observable properties](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/ReactiveCocoa/Swift/Property.swift). Internally, it uses memoization to achieve this, since it needs to cache each newly created property and use it when an operation is about to be used. If it didn't cache each property, it would be impossible to chain and create dependencies between them (for example with `y = x + 5` the variable `y` depends on `x`)

This approaches opens the door to dynamic UI's that rely in mathematical formulas in a simple and expressive way.

### Example

Imagine a scenario where we have one slider and a label that represents the sum of 10 plus the slider's value:

```swift
let y = "x + 10"
```

* `x` is what we would like to change with our slider. 
* `y` is what we would like to observe and eventually update the label with. 
 
It's important to notice that `y` is a read only property (`Property<T>`) while `x` is read/write (`MutableProperty<T>`). The first step is to create a formula (a map between a variable and its equation):

```swift
let formula = ["x": "x", "y": "x + 10"])
```

It needs `"x": "x"`, in order for *formulae* internal parser to understand that this is a `readWrite` observable. The second and final step is to create the observables:
 
 ```swift
let observables = createObservables(withFormula: formula)

guard
   case .some(.readWrite(let propertyX)) = observables["x"],
   case .some(.readOnly(let propertyY)) = observables["y"]
else {
   fatalError("\(observables)")
}
```
 
The output will be a chain of properties that respect what was described: `y = x + 10`. 

```swift
// propertyY.value == 10 ( 0 + 10 )

propertyX.value = 1 // propertyY.value == 11 ( 1 + 10 )
propertyX.value = 2 // propertyY.value == 12 ( 2 + 10 )
```
### Supported Operators

* `+`
* `-`
* `*`
* `/`
* `^`

You can also use parenthesis: `x * ( 2 + 3 )`

## License
*formulae* is licensed under the MIT License, Version 2.0. [View the license file](LICENSE)

Copyright (c) 2016 MailOnline
