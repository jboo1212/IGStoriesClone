//
//  JPlayer.swift
//  InstagramStoriesClone
//
//  Created by Jerome Isaacs on 9/17/18.
//  Copyright © 2018 Jerome Isaacs. All rights reserved.
//

import UIKit
import AVKit

enum TapDirection {
    case none
    case rewind
    case skip
}

protocol JPlayerDelegate: class {
    func willSkipItem(_ player: JPlayer, currentIndex: Int, tapDirection direction: TapDirection)
    func didSkipItem(_ player: JPlayer, previousItem: AVPlayerItem?, tapDirection direction: TapDirection)
}

class JPlayer: AVQueuePlayer {
    
    public var isEmpty: Bool {
        return items().isEmpty
    }
    
    public var count: Int {
        return items().count
    }
    
    public weak var delegate: JPlayerDelegate?
    
    // A copy of the AVItems in the "Queue" since "items()" is constantly changing
    private var copiedItems = [AVPlayerItem]()
    private var copiedItemCurrentIndex: Int = 0
    
    public func addCopiedItems(forItem item: AVPlayerItem) {
        copiedItems.append(item)
    }
    
    // Skips the current track
    // If there are no more tracks to skip, we must send a message to the object chain
    // that we are going forward a Story
    public func skip(skipsAutomatically: Bool) {
        if count != 1 {
            let secondItem = items()[1]
            guard let secondItemIndex = copiedItems.firstIndex(where: {$0 == secondItem}) else { return }
            let _copiedItemCurrentIndex = copiedItemCurrentIndex + 1
            if _copiedItemCurrentIndex != secondItemIndex {
                let nextItem = copiedItems[_copiedItemCurrentIndex]
                insert(nextItem, after: currentItem)
           
            }
            skipHelper(skipsAutomatically: skipsAutomatically)
            copiedItemCurrentIndex = _copiedItemCurrentIndex
        }
            
            // If the last element is not the end, i.e. if we have [a,b,c] and we end up with [b]
            // We would need to insert "c" after "b" 
        else if copiedItemCurrentIndex != copiedItems.count - 1 {
            let _copiedItemCurrentIndex = copiedItemCurrentIndex + 1
            let nextItem = copiedItems[_copiedItemCurrentIndex]
            insert(nextItem, after: currentItem)
            skipHelper(skipsAutomatically: skipsAutomatically)
            copiedItemCurrentIndex = _copiedItemCurrentIndex
        }
            
            // Last element and really at the end, i.e. [c] in our example
        else {
            skipHelper(skipsAutomatically: skipsAutomatically)
            copiedItemCurrentIndex = 0
        }
    }
    
    private func skipHelper(skipsAutomatically: Bool) {
        if skipsAutomatically {
            let previousItem = currentItem
            advanceToNextItem()
            delegate?.didSkipItem(self, previousItem: previousItem, tapDirection: .skip)
        }
        else {
            delegate?.willSkipItem(self, currentIndex: copiedItemCurrentIndex, tapDirection: .skip)
        }
    }
    
    // Rewinds the current track
    // If there are no tracks that we can rewind, we must send a message to the object chain
    // that we are going back a Story
    public func rewind() {
        let previousIndex = copiedItemCurrentIndex - 1
        if copiedItemCurrentIndex != 0 {
            let previousItem = copiedItems[previousIndex]
            insert(previousItem, after: currentItem)
        }
        delegate?.willSkipItem(self, currentIndex: copiedItemCurrentIndex, tapDirection: .rewind)
        copiedItemCurrentIndex = copiedItemCurrentIndex == 0 ? 0: previousIndex
    }
    
    public func goToStart() {
        let beginningTime = CMTimeMakeWithSeconds(0, preferredTimescale: 1)
        currentItem?.seek(to: beginningTime, completionHandler: nil)
    }
    
    public func resetItems() {
        copiedItemCurrentIndex = 0
        copiedItems.removeAll(keepingCapacity: false)
    }
}
