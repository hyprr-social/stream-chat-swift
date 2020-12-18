//
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import UIKit

public struct ChatMessageActionItem {
    public let name: Name
    public let action: () -> Void

    public init(
        name: Name,
        action: @escaping () -> Void
    ) {
        self.name = name
        self.action = action
    }
}

extension ChatMessageActionItem {
    public struct Name: RawRepresentable, Hashable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

public extension ChatMessageActionItem.Name {
    static let inlineReply = Self(rawValue: "inline_reply")
    static let threadReply = Self(rawValue: "thread_reply")
    static let copy = Self(rawValue: "copy")
    static let edit = Self(rawValue: "edit")
    static let delete = Self(rawValue: "delete")
    static let resend = Self(rawValue: "resend")
    static let muteUser = Self(rawValue: "mute_user")
    static let unmuteUser = Self(rawValue: "unmute_user")
    static let blockUser = Self(rawValue: "block_user")
    static let unblockUser = Self(rawValue: "unblock_user")
}
