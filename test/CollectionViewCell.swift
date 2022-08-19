import Foundation
import UIKit

struct CollectionViewCellData {
//    let tabModel: TabModel
    let billIndex: Int
//    var expandedSections: [Int]
    var topInset: CGFloat
    var headerHeight: CGFloat
    weak var delegate: ProfileViewController?
//    var showCalendarSection: Bool
}

final class CollectionViewCell: UICollectionViewCell {
    var layout: UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        return layout
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var contentOffset: CGPoint?
    var headerHeight: CGFloat = 0
    weak var delegate: ProfileViewController?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(Cell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(cellObject: CollectionViewCellData) {
        headerHeight = cellObject.headerHeight
        collectionView.layoutIfNeeded()
        collectionView.contentOffset = CGPoint(x: 0, y: -cellObject.topInset)
        collectionView.contentInset.top = headerHeight
        delegate = cellObject.delegate
    }
    
}

extension CollectionViewCell: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffset = scrollView.contentOffset
        delegate?.tableDidScroll(offset: scrollView.contentOffset, cell: self)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
}
extension CollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        return cell
    }
    
    
}

extension CollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: frame.width, height: 60)
    }
}
