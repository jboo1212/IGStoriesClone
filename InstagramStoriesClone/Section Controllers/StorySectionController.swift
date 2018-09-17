//
//  StorySectionController.swift
//  InstagramStoriesClone
//
//  Created by Jerome Isaacs on 8/5/18.
//  Copyright © 2018 Jerome Isaacs. All rights reserved.
//

import UIKit
import IGListKit

class StorySectionController: ListSectionController {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: viewController)
    }()
    
    private var storyModel: StoryModel?
    
    override init() {
        super.init()
        adapter.dataSource = self
    }
    
    // Collection View Cell for the initial (external) section controller
    override func sizeForItem(at index: Int) -> CGSize {
        guard let width = collectionContext?.containerSize.width else { return .zero }
        let height = width/4.5 + 20
        return CGSize(width: width, height: height)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: EmbeddedStoryCollectionViewCell.self, for: self, at: index) as? EmbeddedStoryCollectionViewCell else { fatalError("Could not return an Embedded Story Collection View Cell") }
        adapter.collectionView = cell.collectionView
        return cell
    }
    
    // Check if 'StoryModel' properly conforms to List Diffable -- IGListKit API requirements.
    override func didUpdate(to object: Any) {
        precondition(object is StoryModel)
        self.storyModel = object as? StoryModel
    }
}

// MARK: ListAdapterDataSource

extension StorySectionController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard let storyModel = storyModel else { return [] }
        return storyModel.stories
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let embeddedStorySectionController = EmbeddedStorySectionController()
        embeddedStorySectionController.storyModel = storyModel
        return embeddedStorySectionController
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {return nil}
}
