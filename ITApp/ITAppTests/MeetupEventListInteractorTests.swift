//
//  MeetupEventListInteractorTests.swift
//  ITAppTests
//
//  Created by Chiaote Ni on 2020/11/2.
//  Copyright © 2020 iOS@Taipei in iPlayground. All rights reserved.
//

import Testing
import Foundation
@testable import ITApp

@Suite("MeetupEventListInteractorTests")
struct MeetupEventListInteractorTests {

    private var sut: MeetupEventListInteractor!
    private var presenterSpy: MeetupEventListPresentationLogicSpy!

    init() throws {
        sut = .init()
        presenterSpy = .init()
        sut.presenter = presenterSpy
    }

    @Test("Fetch Events Should Ask Worker to Fetch and Separate Recently and History Event")
    func testFetchEventsShouldAskWorkerToFetchAndSeparateRecentlyAndHistoryEvent() async {
        let fetchEventsWorker = EventListAPIWorkerSpy()
        sut.cp_resetFetchMeetupEventWorker(worker: fetchEventsWorker)

        let request = MeetupEventList.FetchEvents.Request()
        sut.fetchMeetupEvents(request: request)

        #expect(
            fetchEventsWorker.isFetchMeetupEventsCalled,
            "FetchEventsWorker not called."
        )

        #expect(
            presenterSpy.fetchEventsResponse.recentlyEvents.count == 2,
            "Function to filter recently event goes wrong."
        )
        #expect(
            presenterSpy.fetchEventsResponse.historyEvents.count == 2,
            "Function to filter history event goes wrong."
        )
        #expect(
            presenterSpy.fetchEventsResponse.recentlyEvents[1].meetupEvent.title == Seed.Event.onTodayEvent.title,
            "Function to filter recently event goes wrong."
        )
    }

    @Test("Tap Favorite Should Change Favorite State to the Opposite State")
    func testTapFavoriteShouldChangeFavoriteStateToTheOppositeState() async {
        let fakeEvents: [(MeetupEvent, MeetupEventFavoriteState)] = [
            (Seed.Event.historyEvent, .favorite),
            (Seed.Event.fakeEvent, .unfavorite)
        ]
        sut.cp_resetHistoryEvents(eventResponseItems: fakeEvents)

        let favoriteRequest = MeetupEventList.TapFavorite.Request(meetupEventID: Seed.Event.historyEvent.id)
        sut.tapFavorite(request: favoriteRequest)
        #expect(
            presenterSpy.updateEventsResponse.targetEvent.favoriteState == .unfavorite,
            "TapFavorite UseCase goes wrong."
        )

        let unfavoriteRequest = MeetupEventList.TapFavorite.Request(meetupEventID: Seed.Event.fakeEvent.id)
        sut.tapFavorite(request: unfavoriteRequest)
        #expect(
            presenterSpy.updateEventsResponse.targetEvent.favoriteState == .favorite,
            "TapFavorite UseCase goes wrong."
        )
    }
}

private extension MeetupEventListInteractorTests {

    final class MeetupEventListPresentationLogicSpy: MeetupEventListPresentationLogic {

        var isPresentMeetupEventsCalled = false
        var isPresentUpdateHistoryEventCalled = false

        var fetchEventsResponse: MeetupEventList.FetchEvents.Response!
        var updateEventsResponse: MeetupEventList.UpdateHistoryEvent.Response!

        func presentMeetupEvents(response: MeetupEventList.FetchEvents.Response) {
            isPresentMeetupEventsCalled = true
            fetchEventsResponse = response
        }

        func presentUpdateHistoryEvent(response: MeetupEventList.UpdateHistoryEvent.Response) {
            isPresentUpdateHistoryEventCalled = true
            updateEventsResponse = response
        }
    }

    final class EventListAPIWorkerSpy: MeetupEventListAPIWorker {

        private(set) var isFetchMeetupEventsCalled = false

        override func fetchMeetupEvents(callback: @escaping MeetupEventListAPIWorker.APICallback) {
            isFetchMeetupEventsCalled = true

            let meetupEvents: [MeetupEvent] = [
                Seed.Event.futureEvent,
                Seed.Event.onTodayEvent,
                Seed.Event.historyEvent,
                Seed.Event.fakeEvent
            ]
            callback(.success(meetupEvents))
        }
    }

    enum Seed {
        enum Event {

            static let onTodayEvent: MeetupEvent = .init(
                id: "1",
                title: "Clean Swift",
                description: "介紹Clean Swift的實作",
                coverImageLink: "https://scontent.ftpe11-2.fna.fbcdn.net/v/t1.0-9/122747107_10220912211047274_4719583865875960298_o.jpg?_nc_cat=101&ccb=2&_nc_sid=340051&_nc_ohc=Vu7ppsWcuCMAX8WhHKQ&_nc_ht=scontent.ftpe11-2.fna&oh=d707df5107319e1af4e2741296c2e685&oe=5FC2D3A7",
                hostName: "Aaron & Willian",
                address: "張榮發基金會國際會議中心",
                date: Date()
            )

            static let historyEvent: MeetupEvent = .init(
                id: "2",
                title: "Clean Swift Workshop",
                description: "手把手帶你跑一遍Clean Swift的Workshop",
                coverImageLink: "https://iplayground.io/2020/logo_image.png",
                hostName: "Aaron & Willian",
                address: "張榮發基金會國際會議中心",
                date: Date(timeInterval: -3600 * 24 * 3, since: Date()) // 三天前的活動
            )

            static let futureEvent: MeetupEvent = DummyFactory.makeDummyEvent(
                date: Date(timeInterval: 3600 * 24 * 3, since: Date())
            )
            static let fakeEvent: MeetupEvent = DummyFactory.makeDummyEvent(
                id: "3",
                date: Date(timeInterval: -3600 * 24 * 4, since: Date())
            )
        }
    }
}
