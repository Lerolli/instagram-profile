import UIKit

final class ProfileViewController: UIViewController {
    
    private let headerView = HeaderView()
    private let tabView = TabView()
    private let horizontalCollectionView = HorizontalCollectionView()
    
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
    private var viewModel = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(headerView)
        view.addSubview(horizontalCollectionView)
        view.addSubview(tabView)
        setupConstraint()
        
        scrollToDefault()
        
        horizontalCollectionView.configure(delegate: self)
    }
    
    func scrollToDefault() {
        setHeader(offset: 0)
        horizontalCollectionView.setContentOffset(.zero, animated: false)
    }

    
    private func setupConstraint() {
        horizontalCollectionView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        tabView.translatesAutoresizingMaskIntoConstraints = false
        tabView.delegate = self
        
        NSLayoutConstraint.activate([
            horizontalCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            horizontalCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            horizontalCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            horizontalCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
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
        guard let indexPath = horizontalCollectionView.indexPath(for: cell), indexPath.row == selectedIndex else {
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
            
            tabView.transitSelection(from: selectedIndex, to: nextTabIndex, percent: percent)
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        if index == selectedIndex {
            return
        }
        selectedIndex = index
        tabView.changeSelectedTab(index: selectedIndex)
        horizontalCollectionView.reloadData()
    }

}

extension ProfileViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "VerticalCollectionView",
            for: indexPath
        )
        let topInset = tableTopInset ?? tableTopInset1
        (cell as? VerticalCollectionView)?.configure(cellObject: VerticalCollectionView.CellData(
            billIndex: 0,
            topInset: topInset,
            headerHeight: tableTopInset1,
            delegate: self
        ))
        
        return cell
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.frame.size
    }
}

extension ProfileViewController: TabsViewDelegate {
    func didSelectTab(index: Int) {
        selectedIndex = index
        horizontalCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: [.top, .centeredHorizontally], animated: true)
        horizontalCollectionView.reloadData()
    }
    
    var isDragging: Bool {
         horizontalCollectionView.isDragging || horizontalCollectionView.isDecelerating
    }
}

extension ProfileViewController: HorizontalCollectionViewDelegate {
    func getRectHeaderView() -> [CGRect] {
        return headerView.subviews.map {$0.frame }
    }
    
    func getTextForRow(_ indexPath: IndexPath) -> String {
        switch indexPath.section {
        case 0:
            return viewModel.firstRow[indexPath.row]
        case 1:
            return viewModel.secondRow[indexPath.row]
        case 2:
            return viewModel.thirdRow[indexPath.row]
        default:
            return ""
        }
    }
}
