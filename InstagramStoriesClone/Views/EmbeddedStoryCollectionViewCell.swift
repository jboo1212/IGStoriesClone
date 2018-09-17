//
//  EmbeddedStoryCollectionViewCell.swift
//  InstagramStoriesClone
//
//  Created by Jerome Isaacs on 8/6/18.
//  Copyright © 2018 Jerome Isaacs. All rights reserved.
//

import UIKit

class EmbeddedStoryCollectionViewCell: UICollectionViewCell {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.white
        view.alwaysBounceVertical = false
        view.alwaysBounceHorizontal = true
        view.showsHorizontalScrollIndicator = false
        self.contentView.addSubview(view)
        return view
    }()
    
    lazy var separatorView: UIView = {
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        self.contentView.addSubview(separatorView)
        return separatorView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
        separatorView.frame = CGRect(x: 0, y: contentView.bounds.maxY + 0.5, width: contentView.bounds.width, height: 0.5)
    }
}
