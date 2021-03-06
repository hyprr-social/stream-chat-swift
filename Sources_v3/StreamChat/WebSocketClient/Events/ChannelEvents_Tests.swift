//
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
import XCTest

class ChannelEvents_Tests: XCTestCase {
    let eventDecoder = EventDecoder<DefaultExtraData>()
    
    func test_updated() throws {
        let json = XCTestCase.mockData(fromFile: "ChannelUpdated")
        let event = try eventDecoder.decode(from: json) as? ChannelUpdatedEvent<DefaultExtraData>
        XCTAssertEqual(event?.cid, ChannelId(type: .messaging, id: "new_channel_7070"))
        XCTAssertEqual(event?.userId, "broken-waterfall-5")
    }
    
    func test_deleted() throws {
        let json = XCTestCase.mockData(fromFile: "ChannelDeleted")
        let event = try eventDecoder.decode(from: json) as? ChannelDeletedEvent<DefaultExtraData>
        XCTAssertEqual(event?.cid, ChannelId(type: .messaging, id: "new_channel_6631"))
        XCTAssertEqual(event?.deletedAt.description, "2020-07-17 12:02:39 +0000")
        XCTAssertEqual(event?.userId, "broken-waterfall-5")
    }
    
    func test_hidden() throws {
        // Channel was hidden.
        var json = XCTestCase.mockData(fromFile: "ChannelHidden")
        var event = try eventDecoder.decode(from: json) as? ChannelHiddenEvent<DefaultExtraData>
        XCTAssertEqual(event?.userId, "broken-waterfall-5")
        XCTAssertEqual(event?.cid, ChannelId(type: .messaging, id: "new_channel_7011"))
        XCTAssertEqual(event?.hiddenAt.description, "2020-07-17 12:10:44 +0000")
        XCTAssertFalse(event?.isHistoryCleared ?? true)
        
        // Channel was hidden and the history was cleared.
        json = XCTestCase.mockData(fromFile: "ChannelHiddenCleared")
        event = try eventDecoder.decode(from: json) as? ChannelHiddenEvent<DefaultExtraData>
        XCTAssertEqual(event?.userId, "broken-waterfall-5")
        XCTAssertEqual(event?.cid, ChannelId(type: .messaging, id: "new_channel_1328"))
        XCTAssertEqual(event?.hiddenAt.description, "2020-07-17 12:11:46 +0000")
        XCTAssertTrue(event?.isHistoryCleared ?? false)
    }
}
