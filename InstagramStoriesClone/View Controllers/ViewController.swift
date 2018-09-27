//
//  ViewController.swift
//  InstagramStoriesClone
//
//  Created by Jerome Isaacs on 8/5/18.
//  Copyright © 2018 Jerome Isaacs. All rights reserved.
//

import UIKit
import IGListKit

class ViewController: UIViewController {

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
            .compactMap { URL(string: $0) }
            .map{ StoryItem(id: UUID().uuidString, url: $0) }
        }

        let userWithStories: [String: [String]] = [
            "jeromeythehomie" : ["https://i.imgur.com/OHbkxgr.mp4", "https://i.imgur.com/WvtexT0.mp4", "https://i.imgur.com/fRHHBx2.mp4"]
        ]

        return userWithStories.map { (handler, stories ) in
            return Story(user: getUserFromUsername(handler), isRead: false, storyItems: getStoryFromImage(stories))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

}

extension ViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return [StoryModel(stories: storiesGenerators())]
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return StorySectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
