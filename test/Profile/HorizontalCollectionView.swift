import UIKit

protocol HorizontalCollectionViewDelegate: UICollectionViewDelegate, UICollectionViewDataSource {
    func getRectHeaderView() -> [CGRect]
}

final class HorizontalCollectionView: UICollectionView {
    weak var horizontalDelegate: HorizontalCollectionViewDelegate?
    
    private var layout: UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        return layout
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        super.init(frame: frame, collectionViewLayout: layout)
        
        backgroundColor = .clear
        bounces = false
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false

        register(VerticalCollectionView.self, forCellWithReuseIdentifier: "VerticalCollectionView")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        guard let delegate = horizontalDelegate else {
            return view
        }
        let rects = delegate.getRectHeaderView()

        for rect in rects {
            if point.y <= rect.maxY &&
               point.y >= rect.minY &&
               point.x >= rect.minX &&
               point.x <= rect.maxX {
                return nil
            }
        }
        return view
    }
    
    func configure(delegate: HorizontalCollectionViewDelegate) {
        self.delegate = delegate
        horizontalDelegate = delegate
        dataSource = delegate
    }
}
