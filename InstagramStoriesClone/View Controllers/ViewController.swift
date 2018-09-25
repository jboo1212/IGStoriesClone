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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adapter.performUpdates(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        storyModel = [StoryModel(stories: storiesGenerators())]
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    private func storiesGenerators() -> [Story] {

        let getUserFromUsername: (String) -> User = {
          let imagePath = Bundle.main.url(forResource: $0, withExtension: "jpg")!
          return User(profilePic: imagePath, handle: $0)
        }

        let getStoryFromImage: ([String]) -> [StoryItem] = {
          return $0
            .compactMap { Bundle.main.url(forResource: $0, withExtension: "mov") }
            .map{ StoryItem(id: UUID().uuidString, url: $0) }
        }

        let userWithStories: [String: [String]] = [
            "jeromeythehomie" : ["IMG_0021", "IMG_0460", "IMG_1539"],
            "mattlee077": ["IMG_1636", "IMG_1691", "IMG_1704", "IMG_1705"],
            "asethics": ["IMG_1706"],
            "nat.pat33": ["IMG_1707"]
        ]

        return userWithStories.map { (handler, stories ) in
            return Story(user: getUserFromUsername(handler), isRead: false, storyItems: getStoryFromImage(stories))
        }
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

