# IGStoriesClone
An example project created to show an advanced use case of IGListKit and to fully recreate the awesome Instagram Stories feature on Instagram.


## Features

- [x] 3d cube animation
- [x] Bring up tapped story with custom presentation
- [x] IGListKit Diffing to make the collection fast
- [x] Multiple Story support
- [x] Multiple Story Items per Story (videos)
- [x] Automatic scrolling when Story is done
- [x] Go back a story item with a tap gesture
- [x] Go forward a story item with a tap gesture
- [x] Automatic transition if there are no Stories left

## Example clips

## Clips 1-2

<p>
  <img src = "https://github.com/jboo1212/Assets/blob/master/igstories1.gif">
  <img src = "https://github.com/jboo1212/Assets/blob/master/igstories2.gif">
  </p>
  
## Clips 3-4
<p>
  <img src = "https://github.com/jboo1212/Assets/blob/master/igstories3.gif">
  <img src = "https://github.com/jboo1212/Assets/blob/master/igstories4.gif">
</p>

## Clip 5

<p>
  <img src = "https://github.com/jboo1212/Assets/blob/master/igstories5.gif">
</p>


## Installation

Go to your terminal and clone the repository...Done!

## Usage

For customization, go to ViewController.swift and the Assets folder and add your own movies/profile pictures locally

```swift
import UIKit
import IGListKit

class ViewController: UIViewController, ListAdapterDataSource {
    
    private var storyModel = [StoryModel]()
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adapter.performUpdates(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let stories = modelGenerators()
        let model = StoryModel(stories: stories)
        storyModel = [model]
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }
    
    private func modelGenerators() -> [Story] {
        // Users
        let user1 = User(id: UUID().uuidString, profilePic: Bundle.main.url(forResource: "jeromeythehomie", withExtension: "jpg")!, handle: "jeromeythehomie")
        let user2 = User(id: UUID().uuidString, profilePic: Bundle.main.url(forResource: "mattlee077", withExtension: "jpg")!, handle: "mattlee077")
        let user3 = User(id: UUID().uuidString, profilePic: Bundle.main.url(forResource: "asethics", withExtension: "jpg")!, handle: "asethics")
        let user4 = User(id: UUID().uuidString, profilePic: Bundle.main.url(forResource: "nat.pat33", withExtension: "jpg")!, handle: "nat.pat33")
        
        // Story Items
        let storyItem1 = StoryItem(id: UUID().uuidString, url: Bundle.main.url(forResource: "IMG_0021", withExtension: "mov")!)
        let storyItem2 = StoryItem(id: UUID().uuidString, url: Bundle.main.url(forResource: "IMG_0460", withExtension: "mov")!)
        let storyItem3 = StoryItem(id: UUID().uuidString, url: Bundle.main.url(forResource: "IMG_1539", withExtension: "mov")!)
        let storyItem4 = StoryItem(id: UUID().uuidString, url: Bundle.main.url(forResource: "IMG_1636", withExtension: "mov")!)
        let storyItem5 = StoryItem(id: UUID().uuidString, url: Bundle.main.url(forResource: "IMG_1691", withExtension: "mov")!)
        let storyItem6 = StoryItem(id: UUID().uuidString, url: Bundle.main.url(forResource: "IMG_1704", withExtension: "mov")!)
        let storyItem7 = StoryItem(id: UUID().uuidString, url: Bundle.main.url(forResource: "IMG_1705", withExtension: "mov")!)
        let storyItem8 = StoryItem(id: UUID().uuidString, url: Bundle.main.url(forResource: "IMG_1706", withExtension: "mov")!)
        let storyItem9 = StoryItem(id: UUID().uuidString, url: Bundle.main.url(forResource: "IMG_1707", withExtension: "mov")!)

        // Stories
        let story1 = Story(user: user1, isRead: false, storyItems: [storyItem1, storyItem2, storyItem3])
        let story2 = Story(user: user2, isRead: false, storyItems: [storyItem4, storyItem5, storyItem6, storyItem7])
        let story3 = Story(user: user3, isRead: false, storyItems: [storyItem8])
        let story4 = Story(user: user4, isRead: false, storyItems: [storyItem9])
        let stories = [story1, story2, story3, story4]
        return stories

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return storyModel
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {        
        return StorySectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {return nil}
}

```

## To-do and future releases

- [ ] Fix AVQueuePlayer "flickering" between Stories
- [ ] Dismissing animation and last cell detection with proper animation
- [ ] Pull-to-refresh the Stories such that if the Story has been read, we move it to the end.
- [ ] Fix light gray circle background appearence when read (need help with this one)

## <a name="author"> Author
  
Jerome Isaacs

- [GitHub](https://github.com/jboo1212)
- [Facebook](https://www.facebook.com/jerome.isaacs.12)
- Gmail: jerome.isaacs@gmail.com
