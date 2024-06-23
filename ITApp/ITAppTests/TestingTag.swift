//
//  TestingTag.swift
//  ITAppTests
//
//  Created by Chiaote Ni on 2024/6/23.
//  Copyright © 2024 iOS@Taipei in iPlayground. All rights reserved.
//

import Foundation
import Testing

extension Tag {
    // MARK: - Categories associate to app's use cases for the real life usage
    // These two tags are closer to real-life usage.
    // We can use tags to categorize the tests, then run those tests with a specific tags simultaneously.
    // It’s another categorization tool besides Suite.
    @Tag static var favorite: Self
    @Tag static var dataFlow: Self

    // MARK: - Categories associate to the demonstration of Swift Testing functions
    // We can display the test cases grouping by tags or hierarchy,
    // so please feel free to use these tags in these project to find the test cases that you have a interest.
    // To change the grouping from hierarchy to tags, tap on the leftmost bottom part of the Navigator (the left side-menu) to find the option.
    @Tag static var categorizedTest: Self
    @Tag static var testDescriptions: Self
    @Tag static var parameterizedTest: Self
}
