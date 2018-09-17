//
//  EmbeddedStorySectionController.swift
//  InstagramStoriesClone
//
//  Created by Jerome Isaacs on 8/6/18.
//  Copyright © 2018 Jerome Isaacs. All rights reserved.
//

import UIKit
import IGListKit

class EmbeddedStorySectionController: ListBindingSectionController<Story>, ListBindingSectionControllerDataSource {
    
    // Used to take the tapped profile picture to the current Story
    private let presentStoryboardAnimationController = PresentStoryboardAnimationController()
    
    // Current story
    private var story: Story?
    
    // Pass the story model up the chain since Story Player View Controller will need the list of stories.
    public var storyModel: StoryModel?
    
    // List Binding Magic Sauce to check if the story has been read
    private var localHasRead: Bool?

    // Every section controller will register as an observer if we've advanced, aka, read the story.
    override init() {
        super.init()
        inset = UIEdgeInsetsMake(10, 5, 10, 0)
        dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(storyHasAdvanced(_ :)), name: .StoryHasAdvanced, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .StoryHasAdvanced, object: nil)
    }
    
    // Pass in the particular Story that was advanced, else do nothing.
    // If advanced, mark as 'read.'  Turns the outer container view to a light gray color.
    @objc private func storyHasAdvanced(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let notifiedStory = userInfo["Story"] as? Story, let story = story else { return }
        if notifiedStory.isEqual(toDiffableObject: story) {
            localHasRead = true
            update(animated: true) { (success) in
                if success {
                    print("HOORAY")
                }
            }
        }
    }
    
    // MARK: ListBindingSectionControllerDataSource
    
    // Change the Story to be the same except for the fact that we need to trigger a cell update so add local, mutable variable to init.
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard var object = object as? Story else { fatalError() }
        object = Story(user: object.user, isRead: localHasRead ?? object.isRead, storyItems: object.storyItems)
        story = object
        return [object]
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        guard let cell = collectionContext?.dequeueReusableCell(of: StoryCell.self, for: self, at: index) as? StoryCell else { fatalError("Could not return a Story Cell") }
        cell.tappedPictureDelegate = self
        return cell
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        guard let height = collectionContext?.containerSize.height else { return .zero }
        return CGSize(width: height - 22.5, height: height - 22.5)
    }
}

// MARK: TappedPictureDelegate

extension EmbeddedStorySectionController: TappedPictureDelegate {
    
    // Get the object which we tapped and the frame.
    // Present a Story Player View Controller.
    func didTapPicture(_ picture: UIImageView, cell: StoryCell) {
        guard let viewController = viewController as? ViewController else { return }
        let navigationController = viewController.navigationController
        let storyVC = StoryPlayerViewController(storyModel: storyModel!, story: story!)
        let presentingNavController = UINavigationController(rootViewController: storyVC)
        presentStoryboardAnimationController.startingFrame = cell.frame
        presentingNavController.transitioningDelegate = self
        navigationController?.present(presentingNavController, animated: true)
    }
}

// MARK: UIViewControllerTransitioningDelegate

extension EmbeddedStorySectionController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentStoryboardAnimationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentStoryboardAnimationController
    }
}
