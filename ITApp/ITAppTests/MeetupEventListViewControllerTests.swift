//
//  MeetupEventListViewControllerTests.swift
//  ITAppTests
//
//  Created by Chiaote Ni on 2020/11/3.
//  Copyright © 2020 iOS@Taipei in iPlayground. All rights reserved.
//

import XCTest
import Testing
@testable import ITApp

// 1. The macro @Suite is not required, the struct/class will be marked as a suite automatically when there's a @Test in its scope
// 2. When you use a tag on a suite, all of its tests and sub-suite are with that tag as well
@Suite("MeetupEventListVCTests", .tags(.categorizedTest)) //
struct MeetupEventListVCTests {

    // Useful during developing
    @MainActor @Suite("Behavior within life cycle")
    struct LifeCycleRelatedCases {

        private var sut: MeetupEventListViewController

        init() throws {
            sut = .init()
        }

        // // NOTE:
        //    deinit {
        //        sut = nil
        //    }

        @Test("viewDidLoad - fetch data") // NOTE:
        func viewDidLoadBehavior() {
            let interactorSpy: MeetupEventListBusinessLogicSpy = .init()
            sut.cp_resetInteractor(interactor: interactorSpy)
            sut.viewDidLoad()

            #expect(interactorSpy.isFetchMeetupEventsCalled, "MeetupEventList should fetch events when viewDidLoad.")
        }
    }

    // In this case, this sub-suite has 2 tags: dataFlow & categorizedTest
    @Suite("Data flow", .tags(.dataFlow))
    struct DataFlowCases {

        private var sut: MeetupEventListViewController

        @MainActor
        init() throws {
            sut = .init()
        }

        @MainActor @Test("fetchData - reload TableView ")
        func reloadTableViewAfterFetchData() {
            let spy: TableViewSpy = .init()
            sut.cp_resetTableView(tableView: spy)
            sut.viewDidLoad()

            let viewModel: MeetupEventList.FetchEvents.ViewModel = .init(
                historyEvents: [Seed.Event.historyEvent, Seed.Event.dummyEvent],
                recentlyEvents: []
            )
            sut.displayMeetupEvents(viewModel: viewModel)
            #expect(spy.isReloadDataCalled, "TableView should reload after displayMeetupEvents.")
            #expect(spy.numberOfRows(inSection: 1) == 2, "The number of row sections 1 should be the same as historyEvents amounts.")
        }
    }
}

//final class MeetupEventListViewControllerTests: XCTestCase {
//
//    private var sut: MeetupEventListViewController!
//    
//    override func setUpWithError() throws {
//        sut = .init()
//    }
//
//    override func tearDownWithError() throws {
//        sut = nil
//    }
//
//    // NOTE: we can just add test case with the @Test macro,
//    // and it will display on the Test navigator as well.
//    // However, somehow it wont display the checkbox within the editing area,
//    // and I'm not sure if it's a bug from Xcode or apple intently doing this.
//    @Test @MainActor
//    func viewDidLoadBehavior() {
//        sut = .init()
//        let interactorSpy: MeetupEventListBusinessLogicSpy = .init()
//        sut.cp_resetInteractor(interactor: interactorSpy)
//        sut.viewDidLoad()
//
//        #expect(interactorSpy.isFetchMeetupEventsCalled, "MeetupEventList should fetch events when viewDidLoad.")
//    }
//
//    // NOTE: for more details, please see here:
//    // https://developer.apple.com/documentation/testing/migratingfromxctest
////    func testShouldFetchMeetupEventsWhenViewDidLoad() throws {
////        let interactorSpy: MeetupEventListBusinessLogicSpy = .init()
////        sut.cp_resetInteractor(interactor: interactorSpy)
////        sut.viewDidLoad()
////        
////        XCTAssert(
////            interactorSpy.isFetchMeetupEventsCalled,
////            "MeetupEventList should fetch events when viewDidLoad."
////        )
////    }
//
////    func testShouldUpdateDataSourceAndReloadDataWhenDisplayFetchEvents() throws {
////        let spy: TableViewSpy = .init()
////        sut.cp_resetTableView(tableView: spy)
////        sut.viewDidLoad()
////        
////        let viewModel: MeetupEventList.FetchEvents.ViewModel = .init(
////            historyEvents: [Seed.Event.historyEvent, Seed.Event.dummyEvent],
////            recentlyEvents: []
////        )
////        sut.displayMeetupEvents(viewModel: viewModel)
////        XCTAssert(
////            spy.isReloadDataCalled,
////            "TableView should reload after displayMeetupEvents."
////        )
////        XCTAssert(
////            spy.numberOfRows(inSection: 1) == 2,
////            "The number of row sections 1 should be the same as historyEvents amounts."
////         )
////    }
//}

private class MeetupEventListBusinessLogicSpy: MeetupEventListBusinessLogic {
    var isFetchMeetupEventsCalled: Bool = false

    func fetchMeetupEvents(request: MeetupEventList.FetchEvents.Request) {
        isFetchMeetupEventsCalled = true
    }

    func tapFavorite(request: MeetupEventList.TapFavorite.Request) { }
    func subscribeFavoriteUpdate(request: MeetupEventList.SubscribeFavoriteUpdate.Request) { }
    func unsubscribeFavoriteUpdate(request: MeetupEventList.UnsubscribeFavoriteUpdate.Request) { }
}

private class TableViewSpy: UITableView {
    var isReloadDataCalled: Bool = false

    override func reloadData() {
        isReloadDataCalled = true
    }
}

private enum Seed {
    enum Event {

        static let historyEvent: MeetupEventList.DisplayHistoryEvent = .init(
            id: "1",
            title: "Clean Swift Workshop",
            dateText: "11月08日",
            hostName: "Aaron & Willian",
            coverImageURL: nil,
            favoriteButtonColor: .black
        )

        static let dummyEvent: MeetupEventList.DisplayHistoryEvent = .init(
            id: "2",
            title: "Dummy",
            dateText: "Dummy",
            hostName: "Dummy",
            coverImageURL: nil,
            favoriteButtonColor: .black
        )
    }
}
