//
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import Foundation

/// Coding keys for message-related JSON payloads
enum MessagePayloadsCodingKeys: String, CodingKey {
    case id
    case type
    case user
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case deletedAt = "deleted_at"
    case text
    case command
    case args
    case attachments
    case parentId = "parent_id"
    case showReplyInChannel = "show_in_channel"
    case mentionedUsers = "mentioned_users"
    case threadParticipants = "thread_participants"
    case replyCount = "reply_count"
    case latestReactions = "latest_reactions"
    case ownReactions = "own_reactions"
    case reactionScores = "reaction_scores"
    case isSilent = "silent"
    //        case i18n
}

/// An object describing the wrapped incoming message JSON payload.
struct WrappedMessagePayload<ExtraData: ExtraDataTypes>: Decodable {
    let message: MessagePayload<ExtraData>
}

/// An object describing the incoming message JSON payload.
struct MessagePayload<ExtraData: ExtraDataTypes>: Decodable {
    let id: String
    let type: MessageType
    let user: UserPayload<ExtraData.User>
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let text: String
    let command: String?
    let args: String?
    let parentId: String?
    let showReplyInChannel: Bool
    let mentionedUsers: [UserPayload<ExtraData.User>]
    let threadParticipants: [UserPayload<ExtraData.User>]
    let replyCount: Int
    let extraData: ExtraData.Message
    
    // TODO: Reactions
    // TODO: Translations
    
    let latestReactions: [MessageReactionPayload<ExtraData>]
    let ownReactions: [MessageReactionPayload<ExtraData>]
    let reactionScores: [MessageReactionType: Int]
    let attachments: [AttachmentPayload<ExtraData.Attachment>]
    let isSilent: Bool
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MessagePayloadsCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(MessageType.self, forKey: .type)
        user = try container.decode(UserPayload<ExtraData.User>.self, forKey: .user)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
        text = try container.decode(String.self, forKey: .text).trimmingCharacters(in: .whitespacesAndNewlines)
        isSilent = try container.decodeIfPresent(Bool.self, forKey: .isSilent) ?? false
        command = try container.decodeIfPresent(String.self, forKey: .command)
        args = try container.decodeIfPresent(String.self, forKey: .args)
        parentId = try container.decodeIfPresent(String.self, forKey: .parentId)
        showReplyInChannel = try container.decodeIfPresent(Bool.self, forKey: .showReplyInChannel) ?? false
        mentionedUsers = try container.decode([UserPayload<ExtraData.User>].self, forKey: .mentionedUsers)
        // backend returns `thread_participants` only if message is a thread, we are fine with to have it on all messages
        threadParticipants = try container.decodeIfPresent([UserPayload<ExtraData.User>].self, forKey: .threadParticipants) ?? []
        replyCount = try container.decode(Int.self, forKey: .replyCount)
        latestReactions = try container.decode([MessageReactionPayload<ExtraData>].self, forKey: .latestReactions)
        ownReactions = try container.decode([MessageReactionPayload<ExtraData>].self, forKey: .ownReactions)
        reactionScores = try container
            .decodeIfPresent([String: Int].self, forKey: .reactionScores)?
            .mapKeys { MessageReactionType(rawValue: $0) } ?? [:]
        attachments = try container.decode([AttachmentPayload<ExtraData.Attachment>].self, forKey: .attachments)
        extraData = try ExtraData.Message(from: decoder)
    }
    
    init(
        id: String,
        type: MessageType,
        user: UserPayload<ExtraData.User>,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date? = nil,
        text: String,
        command: String? = nil,
        args: String? = nil,
        parentId: String? = nil,
        showReplyInChannel: Bool,
        mentionedUsers: [UserPayload<ExtraData.User>],
        threadParticipants: [UserPayload<ExtraData.User>] = [],
        replyCount: Int,
        extraData: ExtraData.Message,
        latestReactions: [MessageReactionPayload<ExtraData>] = [],
        ownReactions: [MessageReactionPayload<ExtraData>] = [],
        reactionScores: [MessageReactionType: Int],
        isSilent: Bool,
        attachments: [AttachmentPayload<ExtraData.Attachment>]
    ) {
        self.id = id
        self.type = type
        self.user = user
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.text = text
        self.command = command
        self.args = args
        self.parentId = parentId
        self.showReplyInChannel = showReplyInChannel
        self.mentionedUsers = mentionedUsers
        self.threadParticipants = threadParticipants
        self.replyCount = replyCount
        self.extraData = extraData
        self.latestReactions = latestReactions
        self.ownReactions = ownReactions
        self.reactionScores = reactionScores
        self.isSilent = isSilent
        self.attachments = attachments
    }
}

/// An object describing the outgoing message JSON payload.
struct MessageRequestBody<ExtraData: ExtraDataTypes>: Encodable {
    let id: String
    let user: UserRequestBody<ExtraData.User>
    let text: String
    let command: String?
    let args: String?
    let parentId: String?
    let showReplyInChannel: Bool
    let attachments: [AttachmentRequestBody<ExtraData.Attachment>]
    let extraData: ExtraData.Message
    
    init(
        id: String,
        user: UserRequestBody<ExtraData.User>,
        text: String,
        command: String? = nil,
        args: String? = nil,
        parentId: String? = nil,
        showReplyInChannel: Bool = false,
        attachments: [AttachmentRequestBody<ExtraData.Attachment>] = [],
        extraData: ExtraData.Message
    ) {
        self.id = id
        self.user = user
        self.text = text
        self.command = command
        self.args = args
        self.parentId = parentId
        self.showReplyInChannel = showReplyInChannel
        self.attachments = attachments
        self.extraData = extraData
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: MessagePayloadsCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(command, forKey: .command)
        try container.encodeIfPresent(args, forKey: .args)
        try container.encodeIfPresent(parentId, forKey: .parentId)
        try container.encodeIfPresent(showReplyInChannel, forKey: .showReplyInChannel)
        
        if !attachments.isEmpty {
            try container.encode(attachments, forKey: .attachments)
        }
        
        try extraData.encode(to: encoder)
    }
}

/// An object describing the message replies JSON payload.
struct MessageRepliesPayload<ExtraData: ExtraDataTypes>: Decodable {
    let messages: [MessagePayload<ExtraData>]
}

// TODO: Command???

/// A command in a message, e.g. /giphy.
public struct Command: Codable, Hashable {
    /// A command name.
    public let name: String
    /// A description.
    public let description: String
    public let set: String
    /// Args for the command.
    public let args: String
    
    public init(name: String = "", description: String = "", set: String = "", args: String = "") {
        self.name = name
        self.description = description
        self.set = set
        self.args = args
    }
}
