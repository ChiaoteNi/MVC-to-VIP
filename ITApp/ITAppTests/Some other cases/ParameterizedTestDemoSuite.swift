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
        .tags(.parameterizedTest, .testDescriptions),
        arguments: PresenterTestCase.inputs, PresenterTestCase.outputs
    )
    func timeTransformForDisplay(
        input: PresenterTestCase.Input,
        expected: PresenterTestCase.Expected
    ) async throws {
        
        sut.presentMeetupEvents(response: input)
        
    }
}

enum PresenterTestCase: CustomTestStringConvertible, CaseIterable {

    typealias Input = MeetupEventList.FetchEvents.Response
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

    // MARK: Expected

    var expected: Expected {
        switch self {
        case .nowExpectedToday, .twoHoursLaterExpectedToday, .twoHoursBeforeExpectedToday:
            return .today
        case .twentyFourHoursAfterExpectedFormatted:
            return .formatted(expression: "MM月dd日")
        case .OriginTimeExpectedJaneFirst:
            return .specificString("1月1日")
        }
    }

    enum Expected {
        case today
        case formatted(expression: String)
        case specificString(String)
    }

    // MARK: Utils

    static var inputs: [MeetupEventList.FetchEvents.Response] {
        allCases.map { $0.input }
    }

    static var outputs: [Expected] {
        allCases.map { $0.expected }
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
}

fileprivate
final class MeetupEventListDisplayLogicSpy: MeetupEventListDisplayLogic {

    var isDisplayMeetupEventsCalled: Bool = false
    var isDisplayUpdateHistoryEventCalled: Bool = false

    var fetchEventsViewModel: MeetupEventList.FetchEvents.ViewModel!
    var updateEventsViewModel: MeetupEventList.UpdateHistoryEvent.ViewModel!

    var displayMeetupEventsDone: (() -> Void)?
    var displayUpdateHistoryEventDone: (() -> Void)?

    func displayMeetupEvents(viewModel: MeetupEventList.FetchEvents.ViewModel) {
        isDisplayMeetupEventsCalled = true
        fetchEventsViewModel = viewModel
        displayMeetupEventsDone?()
    }

    func displayUpdateHistoryEvent(viewModel: MeetupEventList.UpdateHistoryEvent.ViewModel) {
        isDisplayUpdateHistoryEventCalled = true
        updateEventsViewModel = viewModel
        displayUpdateHistoryEventDone?()
    }
}
