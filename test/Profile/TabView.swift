import Foundation
import UIKit

protocol TabsCollectionViewDelegate: AnyObject {
    func collectionDidLayout()
}

protocol TabsViewDelegate: AnyObject {
    func didSelectTab(index: Int)
    var isDragging: Bool { get }
}

final class TabsCollectionView: UICollectionView {
    weak var tabsDelegate: TabsCollectionViewDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()

        tabsDelegate?.collectionDidLayout()
    }
}

final class TabView: UIView {
    private var layout: UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        return layout
    }
    private lazy var collectionView = TabsCollectionView(frame: .zero, collectionViewLayout: layout)
    private var separatorView = UIView()
    private var selectionView = UIView()
    var isDragging = false
    weak var delegate: TabsViewDelegate?
    var selectedIndex = 0
    var isAnimationStarted = false

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.tabsDelegate = self
        collectionView.register(TabViewCollectionCell.self, forCellWithReuseIdentifier: "TabViewCollectionCell")
        
        separatorView.backgroundColor = .black
        selectionView.backgroundColor = .red
        
        collectionView.insertSubview(selectionView, aboveSubview: collectionView)
        addSubview(separatorView)
        
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        selectedIndex = 0
        
        
        let indexPath = IndexPath(item: selectedIndex, section: 0)
        collectionView.reloadData()
        if collectionView.numberOfItems(inSection: 0) > selectedIndex {
            collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: true)
        }
    }
    
    func changeSelectedTab(index: Int, animated: Bool = true) {
        
        
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: animated)
        collectionView.reloadData()
        selectedIndex = index
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TabView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate?.didSelectTab(index: indexPath.row)
        changeSelectedTab(index: indexPath.row)
    }
}

extension TabView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "TabViewCollectionCell",
            for: indexPath
        )
        (cell as? TabViewCollectionCell)?.configure(textLabel: String(indexPath.row))
        return cell
    }
}

extension TabView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.size.width / 3, height: collectionView.frame.size.height)
    }
}

extension TabView: TabsCollectionViewDelegate {
    func collectionDidLayout() {
        if let delegate = delegate, !delegate.isDragging {
            selectTab(at: selectedIndex)
        }
    }
}

extension TabView {
    func transitSelection(from startIndex: Int, to endIndex: Int, percent: CGFloat = 0) {
        guard startIndex != endIndex else {
            selectTab(at: startIndex)
            return
        }
        
        let reminder = percent.truncatingRemainder(dividingBy: 1)
        let realPercent = percent > 0 && reminder == 0 ? 1.0 : reminder
        let currentIndex = startIndex < endIndex ? endIndex - 1 : endIndex + 1
        
        let currentCell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0))
        let nextCell = collectionView.cellForItem(at: IndexPath(item: endIndex, section: 0))

        var selectionFrame = selectionView.frame
        
        if let current = currentCell, let next = nextCell {
            let xDiff = (current.frame.minX - next.frame.minX) * realPercent
            let widthDiff = (current.frame.width - next.frame.width) * realPercent
            
            selectionFrame.origin.x = current.frame.minX - xDiff
            selectionFrame.size.width = current.frame.width - widthDiff
        } else if let current = currentCell {
            let mutator: CGFloat = startIndex > endIndex ? -1 : 1
            
            let xDiff = (current.frame.minX - current.frame.maxX) * realPercent * mutator
            
            selectionFrame.origin.x = current.frame.minX - xDiff
        } else if let next = nextCell {
            let mutator: CGFloat = startIndex > endIndex ? -1 : 1
            
            let xDiff = (next.frame.maxX - next.frame.minX) * (1 - realPercent) * mutator
            
            selectionFrame.origin.x = next.frame.minX - xDiff
            selectionFrame.size.width = next.frame.maxX - next.frame.minX
        }
        
        selectionView.frame = selectionFrame
    }

    fileprivate func selectTab(at index: Int) {
        guard selectionView.frame != .zero else {
            setSelectionFrame(for: index)
            return
        }

        if !isAnimationStarted {
            isAnimationStarted = true
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.setSelectionFrame(for: index)
            }) { [weak self] (_) in
                self?.isAnimationStarted = false
            }
        }
    }

    fileprivate func setSelectionFrame(for index: Int) {
        if let item = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
            var selectionFrame = item.frame
            selectionFrame.origin.y = item.frame.height - 2
            selectionFrame.size.height = 2
            selectionView.frame = selectionFrame
        }
    }
}
