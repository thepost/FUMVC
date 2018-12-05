# FUMVC
iOS Fundamentals of MVC.

## Description

FUMVC is a library to demonstrate and provide common architectural abstractions in a very lean way, based on a clean and minimal MVC. Its usage is embedded in the **Fundamentals of MVC**, and is intended to demonstrate how elegant MVC can be despite the FU animosity towards it, hence FUMVC ;)

Initially focuses on Core Data, specifically a Model Controller using generics to reduce boilerplate code in Core Data CRUD operations.

[![Swift: 4.1.x](https://img.shields.io/badge/Swift-4.1.x-orange.svg)](https://swift.org/documentation/#the-swift-programming-language)
[![Platform](https://img.shields.io/cocoapods/p/AFNetworking.svg)](https://cocoapods.org/pods/FUMVC)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Requirements
iOS 11.0 or later, for `NSPersistentContainer` support.

## How to Install

FUMVC is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FUMVC'
```

## How to Use

FUMVC currently has a `ModelController` to be used as an initial abstraction over Core Data. 

You can use the `ModelController`'s convenience initalizer to reference the data model name like the following:


```swift
let modelController = ModelController(modelName: "Model")
```

Then say for example you have an NSManagedObject subclass called Recipe, create a new object like the following:

```swift
let newRecipe = modelController.add(Recipe.self)		
newRecipe?.name = "Pizza"
```

There are other methods for:

    add(type:)
    total(type:)
    fetch(type: predicate: sort:)
    save()
    delete(by objectID:)
    delete(type: predicate:)

## Example

There is a small example with some unit tests. To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author
[Mike Post](https://twitter.com/PostTweetism)

## License

FUMVC is available under the MIT license. See the LICENSE file for more info.
