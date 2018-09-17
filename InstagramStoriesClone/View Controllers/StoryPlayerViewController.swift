//
//  StoryPlayerViewController.swift
//  InstagramStoriesClone
//
//  Created by Jerome Isaacs on 8/6/18.
//  Copyright © 2018 Jerome Isaacs. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class StoryPlayerViewController: UIViewController {
    
    private var storyModel: StoryModel
    private let reuseIdentifier = "Story Player"
    private var willAdvance: Bool = false
    private var tappedIndex: Int = 0
    public weak var storyStatusDelegate: StoryStatusDelegate?
    
    let collectionView: CubeCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = CubeCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPrefetchingEnabled = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        setupCollectionView()
        navigationController?.isNavigationBarHidden = true
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(StoryPlayerCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        if #available(iOS 11, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        // MARK: TODO
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedCollectionView(_ :)))
//        collectionView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(storyWillAdvance(_ :)), name: .StoryWillAdvance, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .StoryWillAdvance, object: PlayerView.self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        
        // The magic sauce behind tapping a Story and retrieiving the right one for the data source to dequeue.
        collectionView.setContentOffset(CGPoint(x: collectionView.frame.width * CGFloat(tappedIndex), y: 0), animated: false)
    }
    
    // MARK: TODO
    @objc private func tappedCollectionView(_ gesture: UITapGestureRecognizer) {
        let leftEdgeRectangle = CGRect(x: 0, y: 0, width: collectionView.frame.width/3, height: collectionView.frame.height)
        let location = gesture.location(in: collectionView)
        if leftEdgeRectangle.contains(location) {
            guard let currentCell = collectionView.visibleCells[0] as? StoryPlayerCell else { return }
            currentCell.playerBackingView.rewind()
            /*
             If we tap back, we need to let the chain of objects know that we're going back a track;
             therefore, the current animation will need to be stopped and reset back to 0, the previous track will need to be played
             and the current item is current item - 1.
 */
        }
        else {
            // Else skip the story item or story depending on how many story items are left.
        }
    }
    
    /*
     Called when we've gone through all the story items in a story and we need to advance to the next Story.
     Tell the data source (Embedded Section Controller, technically) that we've read the current Story.
 */
    @objc private func storyWillAdvance(_ notification: Notification) {
        willAdvance = true
        let currentCell = collectionView.visibleCells[0]
        collectionView.setContentOffset(CGPoint(x: currentCell.frame.origin.x + collectionView.frame.width, y: 0), animated: true)
        guard let indexPath = collectionView.indexPath(for: currentCell) else { return }
        let story = storyModel.stories[indexPath.item]
        NotificationCenter.default.post(name: .StoryHasAdvanced, object: nil, userInfo: ["Story": story])
    }
    
    init(storyModel: StoryModel, story: Story) {
        self.storyModel = storyModel
        super.init(nibName: nil, bundle: nil)
        guard let index = storyModel.stories.index(where: {$0.isEqual(toDiffableObject: story)}) else { fatalError() }
        tappedIndex = index
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: UICollectionViewDataSource

extension StoryPlayerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // The number of cells in the collection represents the number of stories there are for users.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storyModel.stories.count
    }
    
    // Each cell represents a Story containing Story Items.
    // When we set up the cell, we set up the Story Items for the particular Story.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? StoryPlayerCell else { fatalError() }
        let storyItems = storyModel.stories[indexPath.item].storyItems
        cell.playerBackingView.configureStoryItems(storyItems: storyItems)
        cell.storyDismissalDelegate = self
        return cell
    }
}

// MARK: UICollectionViewDelegate

extension StoryPlayerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

// MARK: UIScrollViewDelegate

extension StoryPlayerViewController: UIScrollViewDelegate {
    
    // Pause all stories currently visible and begin animating the collection view
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionView.animateCells()
        collectionView.visibleCells.map { $0 as? StoryPlayerCell }
            .forEach { cell in
                cell?.playerBackingView.pause(willAdvance: willAdvance)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        willAdvance = false
    }
    
    // Start playing the Story
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let cell = collectionView.visibleCells.first as? StoryPlayerCell else { return }
        cell.playerBackingView.play()
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension StoryPlayerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}

extension StoryPlayerViewController: StoryDismissalDelegate {
    func storyWasDismissed() {
        dismiss(animated: true, completion: nil)
    }
}
