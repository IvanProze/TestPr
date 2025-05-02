import UIKit
import Kingfisher

protocol PersonDetailsDisplayLogic: AnyObject {
    func displayData(persons: PersonDetailsModels)
}

struct PersonDetailsModels {
    var imageUrl: URL?
    var text: String
    var name: String
}

// MARK: - View Controller
final class PersonDetailsViewController: UIViewController {
    
    private(set) var router: (PersonDetailsRouterLogic & PersonDetailsDataPassing)?
    
    private var interactor: (PersonDetailsInteractorLogic & PersonDetailsStoreInteractor)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 10
        iv.clipsToBounds = true
        return iv
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var imageHeightConstraint: NSLayoutConstraint?
    private var imageWidthConstraint: NSLayoutConstraint?
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []

    // MARK: - Setup
    
    static func assembleModule(personId: Int) -> UIViewController {
        let viewController = PersonDetailsViewController()
        let interactor = PersonDetailsInteractor()
        let presenter = PersonDetailsPresenter()
        let router = PersonDetailsRouter()
        
        viewController.interactor = interactor
        viewController.router = router
        
        interactor.presenter = presenter
        interactor.personId = personId
        
        presenter.viewController = viewController
        
        router.dataStore = interactor
        
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        interactor?.downloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateLayoutForOrientation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.updateLayoutForOrientation()
        }
    }

    // MARK: - Views

    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(bodyLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        

        portraitConstraints = [
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            bodyLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            bodyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bodyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bodyLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ]
        
        landscapeConstraints = [
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            bodyLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
            bodyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bodyLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ]
        
        imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 200)
        imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 200)
        imageWidthConstraint?.isActive = true
        imageHeightConstraint?.isActive = true
        
        updateLayoutForOrientation()
    }
    
    private func updateLayoutForOrientation() {
        let isPortrait = UIDevice.current.orientation.isPortrait ||
                        (UIDevice.current.orientation != .landscapeLeft &&
                         UIDevice.current.orientation != .landscapeRight)
        
        if isPortrait {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
            
            imageWidthConstraint?.constant = 200
            imageHeightConstraint?.constant = 200
        } else {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
            
            // Smaller image in landscape mode
            imageWidthConstraint?.constant = 150
            imageHeightConstraint?.constant = 150
        }
        
        view.layoutIfNeeded()
    }
}

extension PersonDetailsViewController: PersonDetailsDisplayLogic {
    func displayData(persons: PersonDetailsModels) {
        imageView.kf.setImage(
            with: persons.imageUrl,
            placeholder: UIImage(systemName: "person.fill")
        )
        titleLabel.text = persons.name
        bodyLabel.text = persons.text
    }
}
