//
//  StoryPlayerProgressTrackerView.swift
//  InstagramStoriesClone
//
//  Created by Jerome Isaacs on 8/16/18.
//  Copyright © 2018 Jerome Isaacs. All rights reserved.
//

import UIKit
import AVKit

class StoryPlayerProgressTrackerView: UIStackView {

    public weak var storyPlayerProgressDelegate: StoryPlayerProgressDelegate?
    private var currentTrack: Int = 0
    public var totalTracks: Int = 0
    public var currentTrackLength: Double = 0
    public var isLastCell: Bool = false
    
    private var trackViews = [TrackView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure() {
        createTracks()
    }
    
    private func layout() {
        axis = .horizontal
        alignment = .center
        distribution = .fillProportionally
        spacing = 2
    }
    
    public func skipTrack(forTrack track: Int) {
        trackViews[track].tapDirection = .skip
        trackViews[track].skipAnimation()
    }
    
    public func rewindTrack(forTrack track: Int) {
        let track = trackViews[track]
        if isLastCell {
            track.tapDirection = .none
            track.startOver()
        }
        else {
            track.tapDirection = .rewind
            track.rewindAnimation()
        }
    }
    
    private func createTracks() {
        for i in 0..<totalTracks {
            trackViews.append(TrackView(frame: .zero))
            trackViews[i].progressTrackViewDelegate = self
            trackViews[i].translatesAutoresizingMaskIntoConstraints = false
            trackViews[i].backgroundColor = .darkGray
            trackViews[i].layer.cornerRadius = 1.25
            trackViews[i].heightAnchor.constraint(equalToConstant: 2.5).isActive = true
            addArrangedSubview(trackViews[i])
        }
    }
    
    public func animateCurrentTrack() {
        let currentTrackView = trackViews[currentTrack]
        currentTrackView.performTrackAnimation(duration: currentTrackLength, currentTrack: currentTrack)
    }
    
    public func trackViewCleanup() {
        for trackView in trackViews {
            removeArrangedSubview(trackView)
            trackView.removeFromSuperview()
        }
        trackViews.removeAll(keepingCapacity: false)
    }
}

// MARK: ProgressTrackViewDelegate

/*
 Advances the current track based on a 'successful' completion.
 If we should play next track, the callback in shouldBeginPlaying will advance the item and create the animation chain.
 Else, we've finished watching the tracks and we start back at 0 and remove the track views from the stack view.
 */
extension StoryPlayerProgressTrackerView: ProgressTrackViewDelegate {
    func didFinishAnimatingTrack(forTrack track: Int, tapDirection direction: TapDirection) {
        switch direction {
        case .none, .skip:
            currentTrack += 1
        case .rewind:
            currentTrack -= 1
        }
        let shouldPlayNextTrack = storyPlayerProgressDelegate?.shouldBeginPlayingNextTrack(forTrack: currentTrack, tapDirection: direction) ?? false
        if shouldPlayNextTrack {
            return
        }
        else {
            currentTrack = 0
            storyPlayerProgressDelegate?.didEndPlayingTracks(tapDirection: direction)
            trackViewCleanup()
            isLastCell = false
        }
    }
}

// Track View is the individual track designed to handle the animation and to delegate completion up the object chain.
// The Track View is the gray while the segment is the white - the thing animating across the track view.
class TrackView: UIView {
    
    public weak var progressTrackViewDelegate: ProgressTrackViewDelegate?
    private var trackAnimator: UIViewPropertyAnimator?
    public var tapDirection: TapDirection = .none
    
    private let segmentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(segmentView)
        NotificationCenter.default.addObserver(self, selector: #selector(storyWillPause), name: .StoryWillPause, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(storyWillResume(_:)), name: .StoryWillResume, object: superview)
    }
    
    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: .StoryWillPause, object: nil)
        notificationCenter.removeObserver(self, name: .StoryWillResume, object: superview)
    }
    
    @objc private func storyWillPause() {
        pauseAnimation()
    }
    
    /*
     Since it's possible that the notification can flub and send a resume call to two cells, we only pass the object
     that must handle it in the first place.
     Two cells will have different Progress Tracker Views.
 */
    @objc private func storyWillResume(_ notification: Notification) {
        if notification.object as? UIView == superview {
            resumeAnimation()
        }
    }
    
    public func rewindAnimation() {
        trackAnimator?.fractionComplete = 0
        trackAnimator?.stopAnimation(false)
        trackAnimator?.finishAnimation(at: .start)
    }
    
    public func skipAnimation() {
        trackAnimator?.fractionComplete = 1
        trackAnimator?.stopAnimation(false)
        trackAnimator?.finishAnimation(at: .end)
    }

    private func pauseAnimation() {
        guard let trackAnimator = trackAnimator else { return }
        trackAnimator.pauseAnimation()
    }
    
    public func startOver() {
        trackAnimator?.fractionComplete = 0
    }
    
    public func resumeAnimation() {
        trackAnimator?.fractionComplete = 0
        trackAnimator?.startAnimation()
    }

    /*
     The track animator will only be in one position: end.
     Since it's possible that the segment view frame will be set to the width of the bounds before
     successful completion (like a pause), we must stop this animation.  Else, let the object chain
     know that we would like to go further along the tracks.
 */
    public func performTrackAnimation(duration: Double, currentTrack: Int) {
        segmentView.frame = CGRect(x: 0, y: 0, width: 0, height: bounds.height)
        segmentView.layer.cornerRadius = 2.5
        trackAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: {
            self.segmentView.frame.size.width = self.bounds.width
        })
        trackAnimator?.startAnimation()
        trackAnimator?.addCompletion { (position) in
            switch position {
            case .end:
                if self.segmentView.frame.width == self.bounds.width && self.trackAnimator!.isRunning || self.trackAnimator?.state == .stopped {
                    self.progressTrackViewDelegate?.didFinishAnimatingTrack(forTrack: currentTrack, tapDirection: self.tapDirection)
                }
                else {
                    self.trackAnimator?.stopAnimation(true)
                }
            default: self.progressTrackViewDelegate?.didFinishAnimatingTrack(forTrack: currentTrack, tapDirection: self.tapDirection)
            }
            self.tapDirection = .none
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
