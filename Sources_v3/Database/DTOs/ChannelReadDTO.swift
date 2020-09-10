//
// Copyright © 2020 Stream.io Inc. All rights reserved.
//

import CoreData
import Foundation

@objc(ChannelReadDTO)
class ChannelReadDTO: NSManagedObject {
    static let entityName = "ChannelReadDTO"
    
    @NSManaged var lastReadAt: Date
    @NSManaged var unreadMessageCount: Int
    
    // MARK: - Relationships
    
    @NSManaged var channel: ChannelDTO
    @NSManaged var user: UserDTO
    
    static func fetchRequest(for cid: ChannelId, userId: String) -> NSFetchRequest<ChannelReadDTO> {
        let request = NSFetchRequest<ChannelReadDTO>(entityName: ChannelReadDTO.entityName)
        request.predicate = NSPredicate(format: "channel.cid == %@ && user.id == %@", cid.rawValue, userId)
        return request
    }
    
    static func load(cid: ChannelId, userId: String, context: NSManagedObjectContext) -> ChannelReadDTO? {
        let request = fetchRequest(for: cid, userId: userId)
        return try! context.fetch(request).first
    }
    
    static func loadOrCreate(cid: ChannelId, userId: String, context: NSManagedObjectContext) -> ChannelReadDTO {
        if let existing = Self.load(cid: cid, userId: userId, context: context) {
            return existing
        }
        
        let new = NSEntityDescription.insertNewObject(forEntityName: Self.entityName, into: context) as! ChannelReadDTO
        new.channel = ChannelDTO.loadOrCreate(cid: cid, context: context)
        new.user = UserDTO.loadOrCreate(id: userId, context: context)
        return new
    }
    
    /// Snapshots the current state of `ChannelReadDTO` and returns an immutable model object from it.
    func asModel<ExtraData: ExtraDataTypes>() -> ChannelReadModel<ExtraData> { .create(fromDTO: self) }
}

// MARK: Saving and loading the data

extension NSManagedObjectContext {
    func saveChannelRead<ExtraData: ExtraDataTypes>(
        payload: ChannelReadPayload<ExtraData>,
        for cid: ChannelId
    ) throws -> ChannelReadDTO {
        let dto = ChannelReadDTO.loadOrCreate(cid: cid, userId: payload.user.id, context: self)
        
        dto.user = try saveUser(payload: payload.user)
        
        dto.lastReadAt = payload.lastReadAt
        dto.unreadMessageCount = payload.unreadMessagesCount
        
        return dto
    }
}

extension ChannelReadModel {
    fileprivate static func create(fromDTO dto: ChannelReadDTO) -> ChannelReadModel {
        .init(lastReadAt: dto.lastReadAt, unreadMessagesCount: dto.unreadMessageCount, user: dto.user.asModel())
    }
}