//
//  MeetupEventListAPIWorkerTests.swift
//  ITAppTests
//
//  Created by kuotinyen on 2020/10/27.
//

import Testing
import Foundation
@testable import ITApp

enum MeetupEventListAPIError: Error, Equatable {
    case networkError(code: Int, message: String)
    case unknownError
}

@Suite("MeetupEventListAPIWorkerTests")
struct MeetupEventListAPIWorkerTests {

    @Test("Fetch Meetup Events - Success")
    func testFetchMeetupEventsSuccess() async {
        let sut = MeetupEventListAPIWorker(jsonAPIWorker: JsonAPIWorkerSuccessStub())

        await confirmation("Fetch Meetup Events Success") { completion in
            sut.fetchMeetupEvents { result in
                switch result {
                case let .success(events):
                    #expect(events.count == 26, "Expected 26 events.")
                case .failure:
                    Issue.record("Should not go here.")
                }
                completion()
            }
        }
    }

    @Test("Fetch Meetup Events - Failure")
    func testFetchMeetupEventsFail() async {
        let jsonAPIWorker = JsonAPIWorkerFailureStub()
        jsonAPIWorker.error = MeetupEventListAPIError.networkError(code: 2, message: "Network error")
        let expectedError = MeetupEventListAPIError.networkError(code: 2, message: "Network error")

        let sut = MeetupEventListAPIWorker(jsonAPIWorker: jsonAPIWorker)

        await confirmation("Fetch Meetup Events Failure") { completion in
            sut.fetchMeetupEvents { result in
                switch result {
                case let .failure(error):
                    #expect(error as? MeetupEventListAPIError == expectedError, "Expected error to match.")
                case .success:
                    Issue.record("Should not go here.")
                }
                completion()
            }
        }
    }
}

private extension MeetupEventListAPIWorkerTests {

    final class JsonAPIWorkerSuccessStub: JsonAPIWorker {
        private let jsonFileWorker: JsonFileWorker = .init()

        override func fetchModel<Model>(
            from url: URL,
            callback: @escaping (Result<Model, Error>) -> Void
        ) where Model: Decodable, Model: Encodable {
            jsonFileWorker.fetchModel(from: url.absoluteString, callback: callback)
        }
    }

    final class JsonAPIWorkerFailureStub: JsonAPIWorker {
        private let jsonFileWorker: JsonFileWorker = .init()
        var error: Error!

        override func fetchModel<Model>(
            from url: URL,
            callback: @escaping (Result<Model, Error>) -> Void
        ) where Model: Decodable, Model: Encodable {
            callback(.failure(error))
        }
    }
}
