//
//  InstagramStoriesProtocols.swift
//  InstagramStoriesClone
//
//  Created by Jerome Isaacs on 9/12/18.
//  Copyright © 2018 Jerome Isaacs. All rights reserved.
//

import Foundation

protocol ProgressTrackViewDelegate: class {
    func didFinishAnimatingTrack(forTrack track: Int)
}

protocol StoryPlayerProgressDelegate: class {
    func shouldBeginPlayingNextTrack(forTrack track: Int) -> Bool
    func didEndPlayingTracks()
}

protocol StoryStatusDelegate: class {
    func storyHasAdvanced()
}

protocol StorySectionUpdateDelegate: class {
    func storyHasBeenRead(forStory story: Story)
}

protocol StoryDismissalDelegate: class {
    func storyWasDismissed()
}
