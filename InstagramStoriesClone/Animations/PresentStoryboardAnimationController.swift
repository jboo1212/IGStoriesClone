//
//  PresentStoryboardAnimationController.swift
//  InstagramStoriesClone
//
//  Created by Jerome Isaacs on 8/6/18.
//  Copyright © 2018 Jerome Isaacs. All rights reserved.
//

import UIKit

class PresentStoryboardAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    var startingFrame: CGRect = .zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
/*
         Step 1: Get the frame of the collection view cell that is getting called: this is the starting frame, i.e. where it is in the collection view
         Step 2: CGSize is width, height of the collection view cell
         Step 3: 'To' Frame matches destination/container
         Step 4: End animation.
 */
        guard let toView = transitionContext.view(forKey: .to) else { return }
        let containerView = transitionContext.containerView
        toView.frame = startingFrame
        containerView.addSubview(toView)
        let destinationWidth = containerView.bounds.width
        let destinationHeight = containerView.bounds.height
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.1, delay: 0.1, options: .curveLinear, animations: {
            toView.frame = CGRect(x: 0, y: 0, width: destinationWidth, height: destinationHeight)
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
}
