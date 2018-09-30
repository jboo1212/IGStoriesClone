//
//  StoryCell.swift
//  InstagramStoriesClone
//
//  Created by Jerome Isaacs on 8/5/18.
//  Copyright © 2018 Jerome Isaacs. All rights reserved.
//

import UIKit
import IGListKit

protocol TappedPictureDelegate: class {
    func didTapPicture(_ picture: UIImageView, cell: StoryCell)
}

class StoryCell: UICollectionViewCell {
    
    public weak var tappedPictureDelegate: TappedPictureDelegate?
    
    // Outer circle view for the purple Instagram border
    private let containerView: UIView = {
        let containerView = UIView()
//        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    private let profilePicImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
//        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let handleLabel: UILabel = {
        let handle = UILabel()
        handle.textAlignment = .center
        handle.font = UIFont.systemFont(ofSize: 12, weight: .light)
        handle.text = "Jeromeythehomie"
//        handle.translatesAutoresizingMaskIntoConstraints = false
        return handle
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(containerView)
        containerView.addSubview(profilePicImageView)
        contentView.addSubview(handleLabel)
        profilePicImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedProfilePicture)))
    }
    
    @objc private func tappedProfilePicture() {
        tappedPictureDelegate?.didTapPicture(profilePicImageView, cell: self)
    }
    
    private func setupCircles() {
        let containerHeight = containerView.bounds.height.rounded(.down)
        let profilePictureHeight = profilePicImageView.bounds.height.rounded(.down)
        containerView.layer.borderColor = UIColor(red:0.76, green:0.16, blue:0.64, alpha:1.0).cgColor
        containerView.layer.borderWidth = 2
        containerView.layer.cornerRadius = containerHeight/2
        profilePicImageView.layer.cornerRadius = profilePictureHeight/2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = contentView.bounds
        containerView.frame.size = CGSize(width: containerView.frame.size.width - 15, height: containerView.frame.size.height - 15)
        profilePicImageView.frame = containerView.bounds
        profilePicImageView.frame.size = CGSize(width: containerView.bounds.width - 10, height: containerView.bounds.height - 10)
        profilePicImageView.center = containerView.center
        handleLabel.frame = CGRect(x: 0, y: contentView.frame.maxY - 15, width: contentView.bounds.width, height: 20)
        handleLabel.center.x = containerView.center.x
        setupCircles()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: ListBindable

/*
 If it's our story, set the container view border to a clear color and remove our handle since it's redundant.
 */
extension StoryCell: ListBindable {
    func bindViewModel(_ viewModel: Any) {
        guard let story = viewModel as? Story else { return }
        containerView.layer.borderColor = story.isRead ? UIColor.lightGray.cgColor: UIColor(red:0.76, green:0.16, blue:0.64, alpha:1.0).cgColor
        if story.user.handle == "jeromeythehomie" {
            handleLabel.text = "Your Story"
            containerView.layer.borderColor = UIColor.clear.cgColor
        }
        else {
            handleLabel.text = story.user.handle
        }
        let urlString: String = story.user.profilePic.lastPathComponent
        profilePicImageView.image = UIImage(named: urlString, in: Bundle.main, compatibleWith: nil)
    }
}
