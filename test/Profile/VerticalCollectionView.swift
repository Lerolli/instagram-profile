import UIKit

final class VerticalCollectionView: UICollectionViewCell {
    struct CellData {
        let billIndex: Int
        var topInset: CGFloat
        var headerHeight: CGFloat
        weak var delegate: ProfileViewController?
    }
    
    private var layout: UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        return layout
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
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
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return super.hitTest(point, with: event)
    }
    
    func configure(cellObject: VerticalCollectionView.CellData) {
        headerHeight = cellObject.headerHeight
        collectionView.contentOffset = CGPoint(x: 0, y: -cellObject.topInset)
        collectionView.contentInset.top = headerHeight
        delegate = cellObject.delegate
    }
    
}

extension VerticalCollectionView: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffset = scrollView.contentOffset
        delegate?.tableDidScroll(offset: scrollView.contentOffset, cell: self)
    }
}
extension VerticalCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        (cell as? Cell)?.configure(text: delegate?.getTextForRow(indexPath) ?? "")
        return cell
    }
    
    
}

extension VerticalCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: frame.width, height: 60)
    }
}
