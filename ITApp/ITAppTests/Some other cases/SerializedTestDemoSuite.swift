//
//  SerializedTestSuite.swift
//  ITAppTests
//
//  Created by Chiaote Ni on 2024/6/23.
//  Copyright © 2024 iOS@Taipei in iPlayground. All rights reserved.
//

import Testing

/*
 By default, the suite will execute test cases in parallel.
 Basically, when running unit test, we should replace dependencies with some test doubles, and so for the integration tests; this make the test cases be independent from some side effects and other test cases.
 However, if your test case need to be execute in serialized for some reason due to some dependencies like local storages, using .serialized as the SuiteTrait will solve your problem.
 */
@Suite("Serialized Testing Suite Demo", .serialized)
struct SerializedTestSuite {

    fileprivate let localStorage = FakePersistentStorage()

    @Test
    func s_blahblahblah() async throws {
        // The serialized trail executes the tests in the order of their names instead of from top to bottom.
        // Also, it will execute sub-suite's test case first, then run its own test cases.
        #expect(localStorage.accessCount == 2)
    }
    @Test
    func initialValue() async throws {
        #expect(localStorage.accessCount == 0)
    }
    @Test 
    func plusOne() async throws {
        localStorage.accessCount += 1
        #expect(localStorage.accessCount == 1)
    }
    @Test 
    func plusOneAgain() async throws {
        localStorage.accessCount += 1
        #expect(localStorage.accessCount == 2)
    }

    // A sub Suite will inherit the trait from its parent
    // In this case, the `SubSuite` is inherited the trait `serialized` from the `SerializedTestSuite`
    struct SubSuite {

        enum ExpectedResult: Int, CaseIterable {
            case start
            case plusOne
            case plusOneAgain

            var value: Int { rawValue }
        }

        fileprivate let localStorage = FakePersistentStorage()

        // It's 100% as the same as the implementation in SerializedTestSuite
        @Test(arguments: ExpectedResult.allCases)
        func test(_ expectedResult: ExpectedResult) async throws {
            #expect(localStorage.subAccessCount == expectedResult.value)
            localStorage.subAccessCount += 1
            // Unmark the next line to observe the order of execution for the test cases between sub-suite and the main suite.
//            localStorage.accessCount += 1
        }
    }
}

// MARK: Test Double
extension SerializedTestSuite {

    fileprivate class FakePersistentStorage {

        static var storedValue: Int = 0
        static var subStoredValue: Int = 0

        var accessCount: Int {
            get { Self.storedValue }
            set { Self.storedValue = newValue }
        }

        var subAccessCount: Int {
            get { Self.subStoredValue }
            set { Self.subStoredValue = newValue }
        }
    }
}
