//
//  StoryModel.swift
//  InstagramStoriesClone
//
//  Created by Jerome Isaacs on 8/6/18.
//  Copyright © 2018 Jerome Isaacs. All rights reserved.
//

import Foundation
import IGListKit

/*
 We will only have ONE story model object -- the rest are story objects.
 Leave the 'Diffing' to the sub-models...
 */
final class StoryModel: ListDiffable {
    
    let stories: [Story]
    
    init(stories: [Story]) {
        self.stories = stories
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return "StoryModel" as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return true
    }
}
