//
//  StoryItem.swift
//  InstagramStoriesClone
//
//  Created by Jerome Isaacs on 8/5/18.
//  Copyright © 2018 Jerome Isaacs. All rights reserved.
//

import Foundation
import IGListKit

/*
 A story item can either be: a still image or a video with some length.
 Both are URL's.
 */
final class StoryItem: ListDiffable {
    
    let id: String
    let url: URL
    
    init(id: String, url: URL) {
        self.id = id
        self.url = url
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
}

// MARK: Equatable

extension StoryItem: Equatable {
    // Allow for comparison of story items in an array of story items.
    static func == (lhs: StoryItem, rhs: StoryItem) -> Bool {
        return lhs.id == rhs.id && lhs.url == rhs.url
    }
}
