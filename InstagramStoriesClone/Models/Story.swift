//
//  Story.swift
//  InstagramStoriesClone
//
//  Created by Jerome Isaacs on 8/5/18.
//  Copyright © 2018 Jerome Isaacs. All rights reserved.
//

import Foundation
import IGListKit

/*
 Each story consists of a User, whether or not we've read the current Story, and a list of story items which
 represent the AVAssets or AVPlayerItems in the current Story we're watching.
 */
final class Story: ListDiffable {
    
    let user: User
    let isRead: Bool
    let storyItems: [StoryItem]
    
    init(user: User, isRead: Bool, storyItems: [StoryItem]) {
        self.user = user
        self.isRead = isRead
        self.storyItems = storyItems
    }
    
    // A story is unique from another story based on the identity of the current User.
    func diffIdentifier() -> NSObjectProtocol {
        return user.diffIdentifier()
    }
    
    // The cause of the Story Section Controller to update will be the addition of new Story Items.
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? Story else { return false }
        return isRead == object.isRead && storyItems == object.storyItems
    }
}
