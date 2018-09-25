//
//  User.swift
//  InstagramStoriesClone
//
//  Created by Jerome Isaacs on 8/5/18.
//  Copyright © 2018 Jerome Isaacs. All rights reserved.
//

import Foundation
import IGListKit

final class User: ListDiffable {
    
    let id: String
    let profilePic: URL
    let handle: String
    
    init(id: String = UUID().uuidString, profilePic: URL, handle: String) {
        self.id = id
        self.profilePic = profilePic
        self.handle = handle
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? User else { return false }
        return profilePic == object.profilePic && handle == object.handle
    }
}
