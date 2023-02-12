import Foundation
import UIKit

final class HeaderView: UIView {
    var followButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .blue
        configureFollowButton()
    }
        
    @objc func tap() {
        print("Follow button tap")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureFollowButton() {
        followButton.addTarget(self, action: #selector(tap), for: .touchUpInside)
        followButton.backgroundColor = .red

        addSubview(followButton)
        followButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            followButton.heightAnchor.constraint(equalToConstant: 100),
            followButton.widthAnchor.constraint(equalToConstant: 160),
            followButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            followButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
