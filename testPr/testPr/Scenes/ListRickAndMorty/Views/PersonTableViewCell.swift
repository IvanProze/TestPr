import UIKit
import Kingfisher

struct PersonTableViewCellModel {
    let imageUrl: URL?
    let text: String
    let id: Int
}

protocol PersonTableViewCellDelegate: AnyObject {
    func didTapPersonCell(withId id: Int)
}

final class PersonTableViewCell: UITableViewCell {
    static let identifier = "PersonTableViewCell"
    
    private var personId: Int?
    private weak var delegate: PersonTableViewCellDelegate?
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 1
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let overlayButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        nameLabel.text = nil
        personId = nil
        delegate = nil
    }
    
    func configure(with model: PersonTableViewCellModel, delegate: PersonTableViewCellDelegate) {
        personId = model.id
        nameLabel.text = model.text
        avatarImageView.kf.setImage(
            with: model.imageUrl,
            placeholder: UIImage(systemName: "person.fill")
        )
        self.delegate = delegate
    }
    
    @objc private func didTapCell() {
        guard let id = personId else { return }
        delegate?.didTapPersonCell(withId: id)
    }
    
    private func setupViews() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(overlayButton)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            
            overlayButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            overlayButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            overlayButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            overlayButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
        overlayButton.addTarget(self, action: #selector(didTapCell), for: .touchUpInside)
    }
}
