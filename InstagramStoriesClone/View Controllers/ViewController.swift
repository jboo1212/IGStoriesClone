//
//  ViewController.swift
//  InstagramStoriesClone
//
//  Created by Jerome Isaacs on 8/5/18.
//  Copyright © 2018 Jerome Isaacs. All rights reserved.
//

import UIKit
import IGListKit

class ViewController: UIViewController, ListAdapterDataSource {
    
    private var storyModel = [StoryModel]()
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    let refreshControl = UIRefreshControl()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adapter.performUpdates(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let stories = modelGenerators()
        let model = StoryModel(stories: stories)
        storyModel = [model]
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    private func modelGenerators() -> [Story] {
        // Users
        let user1 = User(id: UUID().uuidString, profilePic: Bundle.main.url(forResource: "jeromeythehomie", withExtension: "jpg")!, handle: "jeromeythehomie")
        let user2 = User(id: UUID().uuidString, profilePic: Bundle.main.url(forResource: "mattlee077", withExtension: "jpg")!, handle: "mattlee077")
        let user3 = User(id: UUID().uuidString, profilePic: Bundle.main.url(forResource: "asethics", withExtension: "jpg")!, handle: "asethics")
        let user4 = User(id: UUID().uuidString, profilePic: Bundle.main.url(forResource: "nat.pat33", withExtension: "jpg")!, handle: "nat.pat33")
        
        // Story Items
        let storyItem1 = StoryItem(id: UUID().uuidString, url: Bundle.main.url(forResource: "IMG_0021", withExtension: "mov")!)
        let storyItem2 = StoryItem(id: UUID().uuidString, url: Bundle.main.url(forResource: "IMG_0460", withExtension: "mov")!)
        let storyItem3 = StoryItem(id: UUID().uuidString, url: Bundle.main.url(forResource: "IMG_1539", withExtension: "mov")!)
        let storyItem4 = StoryItem(id: UUID().uuidString, url: Bundle.main.url(forResource: "IMG_1636", withExtension: "mov")!)
        let storyItem5 = StoryItem(id: UUID().uuidString, url: Bundle.main.url(forResource: "IMG_1691", withExtension: "mov")!)
        let storyItem6 = StoryItem(id: UUID().uuidString, url: Bundle.main.url(forResource: "IMG_1704", withExtension: "mov")!)
        let storyItem7 = StoryItem(id: UUID().uuidString, url: Bundle.main.url(forResource: "IMG_1705", withExtension: "mov")!)
        let storyItem8 = StoryItem(id: UUID().uuidString, url: Bundle.main.url(forResource: "IMG_1706", withExtension: "mov")!)
        let storyItem9 = StoryItem(id: UUID().uuidString, url: Bundle.main.url(forResource: "IMG_1707", withExtension: "mov")!)

        // Stories
        let story1 = Story(user: user1, isRead: false, storyItems: [storyItem1, storyItem2, storyItem3])
        let story2 = Story(user: user2, isRead: false, storyItems: [storyItem4, storyItem5, storyItem6, storyItem7])
        let story3 = Story(user: user3, isRead: false, storyItems: [storyItem8])
        let story4 = Story(user: user4, isRead: false, storyItems: [storyItem9])
        let stories = [story1, story2, story3, story4]
        return stories

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return storyModel
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {        
        return StorySectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {return nil}
}

