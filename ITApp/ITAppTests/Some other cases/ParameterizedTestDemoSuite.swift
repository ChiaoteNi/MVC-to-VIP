//
//  ParameterizedTestDemoSuite.swift
//  ITAppTests
//
//  Created by Chiaote Ni on 2024/6/23.
//  Copyright © 2024 iOS@Taipei in iPlayground. All rights reserved.
//

import Foundation
import Testing
@testable import ITApp

struct PresenterTestSuite {

    private let sut: MeetupEventListPresenter
    private let viewControllerSpy: MeetupEventListDisplayLogicSpy

    init() async {
        sut = MeetupEventListPresenter()
        viewControllerSpy = MeetupEventListDisplayLogicSpy()
        sut.viewController = viewControllerSpy
    }

    @Test(
        "Transformation to convert date to a displaying string",
        .tags(.parameterizedTest),
        arguments: [
            Date(),
            Date().addingTimeInterval(3 * 3600),
            Date().addingTimeInterval(-3 * 3600),
            Date().addingTimeInterval(24 * 3600),
            Date().addingTimeInterval(1.25 * 3600),
            Date().addingTimeInterval(12 * 30 * 3600),
        ]
    )
    func timeTransformForDisplay(seed: Date) async throws {
        let input = makeInput(with: seed)
        sut.presentMeetupEvents(response: input)

        let viewModel = await withCheckedContinuation { continuation in
            viewControllerSpy.displayMeetupEventsDone = { viewModel in
                continuation.resume(returning: viewModel)
            }
        }
        let result = try #require(viewModel.recentlyEvents.first)

        let targetPattern = #"^\d{2}月\d{2}日$"#
//        let targetPattern = #"^\d{2}月\d{2}日.*$"#
        #expect(result.dateText.matches(regex: targetPattern))
    }

//    @Test(
//        "Transformation to convert date to a displaying string with test descriptions",
//        .tags(.parameterizedTest, .testDescriptions),
//        arguments: PresenterTestCase.allCases
//    )
//    fileprivate func timeTransformForDisplay(testCase: PresenterTestCase) async throws {
//        sut.presentMeetupEvents(response: testCase.input)
//
//        let viewModel = await withCheckedContinuation { continuation in
//            viewControllerSpy.displayMeetupEventsDone = { viewModel in
//                continuation.resume(returning: viewModel)
//            }
//        }
//        let result = try #require(viewModel.recentlyEvents.first)
//
//        switch testCase.expected {
//        case .today:
//            #expect(result.dateText.contains("(今天)"))
//        case let .specificString(string):
//            #expect(result.dateText == string)
//        case let .formatted(expression):
//            #expect(result.dateText.matches(regex: expression))
//        }
//    }
}

// MARK: - Test cases

fileprivate enum PresenterTestCase: CustomTestStringConvertible, CaseIterable {

    // These enum cases are extremely hard to read.
    // Even if we change the case by removing the last part of Expected..., it sill difficult to understand what the test case is due to missing information.
    case nowExpectedToday
    case twoHoursLaterExpectedToday
    case twoHoursBeforeExpectedToday
    case twentyFourHoursAfterExpectedFormatted
    case OriginTimeExpectedJaneFirst

    var testDescription: String {
        switch self {
        case .nowExpectedToday:
            return "Input 'now' - expected to transform to 'today'"
        case .twoHoursLaterExpectedToday:
            return "Input 'now + 2 hours' - expected to transform to 'today'"
        case .twoHoursBeforeExpectedToday:
            return "Input 'now - 2 hours' - expected to transform to 'today'"
        case .twentyFourHoursAfterExpectedFormatted:
            return "Input 'now + 24 hours' - expected to transform to 'MM月dd日'"
        case .OriginTimeExpectedJaneFirst:
            return "Input 1970/01/01 - expected to transform to '1月1日'"
        }
    }

    // MARK: Input

    var input: Input {
        switch self {
        case .nowExpectedToday:
            return makeInput(with: Date())
        case .twoHoursLaterExpectedToday:
            return makeInput(with: Date().addingTimeInterval(2 * 60 * 60))
        case .twoHoursBeforeExpectedToday:
            return makeInput(with: Date().addingTimeInterval(-2 * 60 * 60))
        case .twentyFourHoursAfterExpectedFormatted:
            return makeInput(with: Date().addingTimeInterval(24 * 60 * 60))
        case .OriginTimeExpectedJaneFirst:
            return makeInput(with: Date(timeIntervalSince1970: 0))
        }
    }
    typealias Input = MeetupEventList.FetchEvents.Response

    // MARK: Expected

    var expected: Expected {
        switch self {
        case .nowExpectedToday, .twoHoursLaterExpectedToday, .twoHoursBeforeExpectedToday:
            return .today
        case .twentyFourHoursAfterExpectedFormatted:
            // A regex patten for 'MM月dd日'
            return .formatted(pattern: #"^\d{2}月\d{2}日$"#)
        case .OriginTimeExpectedJaneFirst:
            return .specificString("01月01日")
        }
    }

    enum Expected {
        case today
        case formatted(pattern: String)
        case specificString(String)
    }

    // MARK: Utils

    static var inputs: [MeetupEventList.FetchEvents.Response] {
        allCases.map { $0.input }
    }

    static var outputs: [Expected] {
        allCases.map { $0.expected }
    }
}

fileprivate class MeetupEventListDisplayLogicSpy: MeetupEventListDisplayLogic {

    typealias FetchEventsViewModel = MeetupEventList.FetchEvents.ViewModel
    typealias UpdateEventsViewModel = MeetupEventList.UpdateHistoryEvent.ViewModel

    var isDisplayMeetupEventsCalled: Bool = false
    var isDisplayUpdateHistoryEventCalled: Bool = false

    var fetchEventsViewModel: FetchEventsViewModel?
    var updateEventsViewModel: UpdateEventsViewModel?

    var displayMeetupEventsDone: ((_ fetchEventsViewModel: FetchEventsViewModel) -> Void)? {
        didSet {
            guard let viewModel = fetchEventsViewModel else { return }
            displayMeetupEventsDone?(viewModel)
        }
    }
    var displayUpdateHistoryEventDone: ((_ updateEventsViewModel: UpdateEventsViewModel) -> Void)? {
        didSet {
            guard let viewModel = updateEventsViewModel else { return }
            displayUpdateHistoryEventDone?(viewModel)
        }
    }

    func displayMeetupEvents(viewModel: FetchEventsViewModel) {
        isDisplayMeetupEventsCalled = true
        fetchEventsViewModel = viewModel
        displayMeetupEventsDone?(viewModel)
    }

    func displayUpdateHistoryEvent(viewModel: UpdateEventsViewModel) {
        isDisplayUpdateHistoryEventCalled = true
        updateEventsViewModel = viewModel
        displayUpdateHistoryEventDone?(viewModel)
    }
}

// MARK: - Util functions

private extension String {
    func matches(regex pattern: String) -> Bool {
        range(of: pattern, options: .regularExpression) != nil
    }
}

private func makeInput(with time: Date) -> MeetupEventList.FetchEvents.Response {
    let event = MeetupEvent(
        id: "1",
        title: "Dummy Event",
        description: nil,
        coverImageLink: nil,
        hostName: "Dummy author",
        address: nil,
        date: time
    )
    return MeetupEventList.FetchEvents.Response(
        recentlyEvents: [(event, .unfavorite)],
        historyEvents: []
    )
}
