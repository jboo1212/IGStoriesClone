//
//  StoryPlayerCell.swift
//  InstagramStoriesClone
//
//  Created by Jerome Isaacs on 8/13/18.
//  Copyright © 2018 Jerome Isaacs. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import IGListKit

extension NSNotification.Name {
    static let StoryWillAdvance: NSNotification.Name = NSNotification.Name("storyWillAdvance")
    static let StoryWillPause: NSNotification.Name = NSNotification.Name("storyWillPause")
    static let StoryWillResume: NSNotification.Name = NSNotification.Name("storyWillResume")
    static let StoryWillRewind: NSNotification.Name = NSNotification.Name("storyWillRewind")
    static let StoryHasAdvanced: NSNotification.Name = NSNotification.Name("storyHasAdvanced")
    static let StoryHasSkipped: NSNotification.Name = NSNotification.Name("storyHasSkipped")
}

class StoryPlayerCell: UICollectionViewCell {
    
    public weak var storyDismissalDelegate: StoryDismissalDelegate?
    @objc public let playerBackingView = PlayerBackingView()
    
    private let dismissButton: UIButton = {
        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        dismissButton.tintColor = .white
        return dismissButton
    }()
    
    // Perform some necessary cleanup based on cell reuse since we run into issues if we don't
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.transform = CATransform3DIdentity
        adjustAnchorPoint()
        playerBackingView.observedCount = 0
        playerBackingView.player.resetItems()
        playerBackingView.playerProgressTrackerView.trackViewCleanup()
        playerBackingView.player.removeAllItems()
        playerBackingView.oldStoryItems.removeAll()
        playerBackingView.shouldResume = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(playerBackingView)
        contentView.addSubview(dismissButton)
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerBackingView.frame = bounds
        let statusBarHeight: CGFloat = 20
        if UIScreen.main.nativeBounds.height == 2436 {
            dismissButton.frame = CGRect(x: contentView.frame.width - 40, y: 2 * statusBarHeight + 10, width: 40, height: 40)
        }
        else {
            dismissButton.frame = CGRect(x: contentView.frame.width - 40, y: contentView.frame.minY + 20, width: 40, height: 40)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func dismissButtonTapped() {
        storyDismissalDelegate?.storyWasDismissed()
    }
}

private var playerViewControllerKVOContext = 0

// Player Backing View handles the main logic of playing and pausing tracks.
class PlayerBackingView: UIView {
    
    public var isLastCell: Bool = false
    
    // Main player to use for the AVPlayerItems
    @objc public var player = JPlayer()
    
    // Keep track of the items since cell reuse
    public var oldStoryItems = [StoryItem]()
    
    // Whether or not to pause the animation
    public var shouldResume: Bool = false
    
    // The actual backing view for the AVPlayerLayer
    private let playerView = PlayerView()
    
    // Stack view used for the track views
    public let playerProgressTrackerView = StoryPlayerProgressTrackerView()
    public var currentTrackLength: Double = 0
    
    // Counter so we don't call animateTrack twice.
    public var observedCount: Int = 0
    
    public var hasTapped: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(playerView)
        playerView.addSubview(playerProgressTrackerView)
        playerView.player = player
        player.delegate = self
        playerProgressTrackerView.storyPlayerProgressDelegate = self
        addObserver(self, forKeyPath: #keyPath(player.currentItem.duration), options: [.initial, .new], context: &playerViewControllerKVOContext)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver(self, forKeyPath: #keyPath(player.currentItem.duration), context: &playerViewControllerKVOContext)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerView.frame = bounds
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Make sure the this KVO callback was intended for this view.
        guard context == &playerViewControllerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        if keyPath == #keyPath(player.currentItem.duration) {
            /*
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            let newDuration: CMTime
            if let newDurationAsValue = change?[NSKeyValueChangeKey.newKey] as? NSValue{
                newDuration = newDurationAsValue.timeValue
            }
            else {
                newDuration = CMTime.zero
            }
            playerProgressTrackerView.currentTrackLength = CMTimeGetSeconds(newDuration)
            currentTrackLength = CMTimeGetSeconds(newDuration)
            if currentTrackLength > 0 {
                observedCount += 1
            }
            if playerProgressTrackerView.currentTrackLength > 0 && observedCount == 1 {
                playerProgressTrackerView.animateCurrentTrack()
            }
        }
    }

    public func play() {
        if shouldResume {
            NotificationCenter.default.post(name: .StoryWillResume, object: playerProgressTrackerView)
            shouldResume = false
        }
        player.play()
    }

    /*
     Pauses the video, seeks the playback time back to 0.
     Also, we post a "StoryWillPause" notification to the Track View to let it know
     that we're going to effect the state of the animation.
 */
    public func pause(willAdvance: Bool) {
        if !willAdvance {
            player.pause()
            let beginningTime = CMTimeMakeWithSeconds(0, preferredTimescale: 1)
            player.seek(to: beginningTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            shouldResume = true
            NotificationCenter.default.post(name: .StoryWillPause, object: nil)
        }
    }
    
    /*
     Since cells are re-used and we do not want to insert "New" Story items
     back into the array (which is not permitted and will cause your application to crash),
     we diff the cells and find which indices changes, inserting them at the proper start index.
     
     If nothing has changed, we simply insert AVPlayerItems into the queue.
     
     Begin playing and setting up the tracks regardless.
 */
    public func configureStoryItems(storyItems: [StoryItem]) {
        let diffInsertIndices = diffStoryItems(newStoryItems: storyItems)
        if oldStoryItems.isEmpty {
            oldStoryItems = storyItems
            for item in storyItems {
                let item = AVPlayerItem(url: item.url)
                player.insert(item, after: player.items().last)
                player.addCopiedItems(forItem: item)
            }
        }
        else if diffInsertIndices.count >= 1 {
            oldStoryItems = storyItems
            guard let startInsertIndex = diffInsertIndices.first else { return }
            for item in startInsertIndex..<storyItems.count {
                let url = storyItems[item].url
                let item = AVPlayerItem(url: url)
                player.insert(item, after: player.items().last)
                player.addCopiedItems(forItem: item)
            }
        }
        setupTracker()
        play()
    }

    /*
     IGListKit Diffing Algorithm ---
     Since Story Items are 'Diffable' we can perform 'Diffs' on them to find where the inserts happened in the array.
 */
    private func diffStoryItems(newStoryItems storyItems: [StoryItem]) -> IndexSet {
        let result = ListDiff(oldArray: oldStoryItems, newArray: storyItems, option: .equality)
        return result.inserts
    }

    /*
     Tell the progress track view how many tracks we need to configure.
 */
    private func setupTracker() {
        let width = UIScreen.main.bounds.width
        let padding: CGFloat = 5
        let statusBarHeight: CGFloat = 20
        if UIScreen.main.nativeBounds.height == 2436 {
            playerProgressTrackerView.frame = CGRect(x: 2 * padding, y: statusBarHeight + (3 * padding), width: width - (4 * padding), height: padding)
        }
        else {
           playerProgressTrackerView.frame = CGRect(x: 2 * padding, y: frame.minY + (2 * padding), width: width - (4 * padding), height: padding)
        }
        playerProgressTrackerView.totalTracks = player.items().count
        playerProgressTrackerView.configure()
    }
}

// MARK: StoryPlayerProgressDelegate

extension PlayerBackingView: StoryPlayerProgressDelegate {
    
    func shouldBeginPlayingNextTrack(forTrack track: Int, tapDirection direction: TapDirection) -> Bool {
        observedCount = 0
        if track + 1 > oldStoryItems.count || track == -1 {
            return false
        }
        else {
            if hasTapped {
                player.advanceToNextItem()
            }
            else {
                player.skip(skipsAutomatically: true)
            }
            hasTapped = false
            player.goToStart()
            return true
        }
    }

    // Depending on which direction that was tapped that triggered an end will dictate which Notification we will need to post.
    func didEndPlayingTracks(tapDirection direction: TapDirection) {
        switch direction {
        case .none, .skip:
            NotificationCenter.default.post(name: .StoryWillAdvance, object: nil)
        case .rewind:
            NotificationCenter.default.post(name: .StoryWillRewind, object: nil)
        }
    }
}

// MARK: JPlayerDelegate

extension PlayerBackingView: JPlayerDelegate {
    func willSkipItem(_ player: JPlayer, currentIndex: Int, tapDirection direction: TapDirection) {
        switch direction {
        case .skip: playerProgressTrackerView.skipTrack(forTrack: currentIndex)
        default:
            if isLastCell {
                playerProgressTrackerView.isLastCell = true
                player.goToStart()
            }
            playerProgressTrackerView.rewindTrack(forTrack: currentIndex)
        }
    }
    
    func didSkipItem(_ player: JPlayer, previousItem: AVPlayerItem?, tapDirection direction: TapDirection) {
        print("did skip item")
    }
}

// Apple docs https://developer.apple.com/documentation/avfoundation/avplayerlayer
class PlayerView: UIView {

    @objc var player: JPlayer? {
        get {
            return playerLayer.player as? JPlayer
        }
        set {
            playerLayer.player = newValue
        }
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer.videoGravity = .resizeAspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
