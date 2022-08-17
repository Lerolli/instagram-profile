import UIKit

class ProfileViewController: UIViewController {
    private var headerView = UIView()
    private var tabView = UIView()
    private var layout: UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        return layout
    }
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    
    private var headerTopContraint: NSLayoutConstraint?
    private var headerViewHeight: CGFloat {
        headerView.frame.height
    }
    private var tabViewHeight: CGFloat {
        tabView.frame.height
    }
    private var tableTopInset: CGFloat?
    private var tableTopInset1: CGFloat {
        headerViewHeight
    }
    
    private var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = false
        collectionView.isPagingEnabled = true
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        
        headerView.layer.borderWidth = 1
        headerView.layer.borderColor = UIColor.red.cgColor
        
        tabView.layer.borderWidth = 1
        tabView.layer.borderColor = UIColor.blue.cgColor
        
        view.addSubview(collectionView)
        view.addSubview(headerView)
        view.addSubview(tabView)
        setupConstraint()
        scrollToDefault()
    }
    
    func scrollToDefault() {
        setHeader(offset: 0)
        collectionView.setContentOffset(.zero, animated: false)
    }


    private func setupConstraint() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        tabView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 375),
            headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tabView.heightAnchor.constraint(equalToConstant: 66),
            tabView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            tabView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tabView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        headerTopContraint = headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        NSLayoutConstraint.activate([headerTopContraint].compactMap({$0}))
    }
    
    func tableDidScroll(offset: CGPoint, cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell), indexPath.row == selectedIndex else {
            return
        }
        
        var coordY = -offset.y - headerViewHeight
        
        if -offset.y - tabViewHeight <= 0 {
            coordY = -headerViewHeight + tabViewHeight
        }
        updateTable(inset: -offset.y)
        setHeader(offset: coordY)
    }
    
    func setHeader(offset: CGFloat) {
        headerTopContraint?.constant = offset
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
    }
    
    func updateTable(inset: CGFloat) {
        tableTopInset = inset
    }
    
}

extension ProfileViewController: UICollectionViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isDragging {
            let offsetForSelected = scrollView.frame.width * CGFloat(selectedIndex)
            let newOffset = scrollView.contentOffset.x
            let percent = abs(offsetForSelected - newOffset) / scrollView.frame.width
            let nextTabIndex = newOffset < offsetForSelected ? selectedIndex - Int(ceil(percent)) : selectedIndex + Int(ceil(percent))
            
//            tabView.transitSelection(from: selectedIndex, to: nextTabIndex, percent: percent)
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        if index == selectedIndex {
            return
        }
        selectedIndex = index
//        tabView.changeSelectedTab(index: selectedIndex)
        collectionView.reloadData()
    }

}

extension ProfileViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)
        let topInset = tableTopInset ?? tableTopInset1
        (cell as? CollectionViewCell)?.configure(cellObject: CollectionViewCellData(billIndex: 0, topInset: topInset, headerHeight: tableTopInset1, delegate: self))
        return cell
    }
}



extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.frame.size
    }
}

extension ProfileViewController {
    var isDragging: Bool {
         collectionView.isDragging || collectionView.isDecelerating
    }
}
