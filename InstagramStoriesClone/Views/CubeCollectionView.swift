//
//  CubeCollectionView.swift
//  InstagramStoriesClone
//
//  Created by Jerome Isaacs on 8/14/18.
//  Copyright © 2018 Jerome Isaacs. All rights reserved.
//

import UIKit

class CubeCollectionView: UICollectionView {
    
    private func toRadians(_ number: CGFloat) -> CGFloat {
        return number * .pi / 180
    }
    
    private var identity: CATransform3D = {
        var identity = CATransform3DIdentity
        identity.m34 = 1/1000
        return identity
    }()
    
    func resetIdentity() {
        identity.m34 = (identity.m34 == 0) ? 1/1000: 0
    }
    
    public func animateCells() {
        visibleCells.forEach { (cell) in
            cell.layer.transform = computeTransform(forCell: cell)
        }
    }
    
    /*
     Inspiration from Joey Bodnar's approach using Scroll Views
     https://www.vaporforums.io/viewThread/53
     
     The left cell goes from [0, 90] while the right cell goes from [-90, 0].
     We track how far the animation has gone based on the absolute value of the offset
     adjusted by the width of the frame for the screen in multiples of 1, 2, 3, .. etc.
     
     i.e. 650/375 = 1.73 but since we just care about the values from [0, 1], we can simply
     get rid of the single digit (1).  The animation is 73% complete.
     This would mean that the left cell is the second cell and the right cell is the third cell.
 */
    private func computeTransform(forCell cell: UICollectionViewCell) -> CATransform3D {

        let cells = visibleCells.sorted(by: {$0.frame.origin.x > $1.frame.origin.x})
        var degree: CGFloat
        let leftAnchorPoint = CGPoint(x: 1, y: 0.5)
        let rightAnchorPoint = CGPoint(x: 0, y: 0.5)
        let progress: CGFloat
        let xOffset = contentOffset.x
        
        progress = abs((xOffset / frame.width).truncatingRemainder(dividingBy: 1))
        if progress == 0 {
            cell.adjustAnchorPoint()
            resetIdentity()
            return CATransform3DRotate(identity, 0, 0, 1, 0)
        }
        identity.m34 = 1/1000
        let isLeftCell = cells.last == cell
        
        // MARK: TODO
        // Hacky approach for when there's no cells visible.
//        if cells.first == cells.last {
//            cell.adjustAnchorPoint(rightAnchorPoint)
//            degree = toRadians(90 * progress)
//            let viewController = dataSource as? StoryPlayerViewController
//            if progress >= 0.15 {
//                viewController?.dismiss(animated: true, completion: nil)
//            }
//            return CATransform3DRotate(identity, degree, 0, -1, 0)
//        }

        let leftCell: UICollectionViewCell
        let rightCell: UICollectionViewCell
        if isLeftCell {
            leftCell = cell
            leftCell.adjustAnchorPoint(leftAnchorPoint)
            degree = toRadians(90 * progress)
            return CATransform3DRotate(identity, degree, 0, 1, 0)
        }
        else {
            rightCell = cell
            rightCell.adjustAnchorPoint(rightAnchorPoint)
            degree = toRadians((1 - progress) * -90)
            return CATransform3DRotate(identity, degree, 0, 1, 0)
        }
    }
}

extension UIView {
    func adjustAnchorPoint(_ anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
        var newPoint = CGPoint(x: bounds.size.width * anchorPoint.x, y: bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y)
        
        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)
        
        var position = layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        layer.position    = position
        layer.anchorPoint = anchorPoint
    }
}
