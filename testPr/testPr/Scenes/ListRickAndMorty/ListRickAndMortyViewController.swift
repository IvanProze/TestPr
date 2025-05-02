import UIKit
import RickMortySwiftApi

protocol ListRickAndMortyDisplayLogic: AnyObject {
    func displayData(persons: [PersonTableViewCellModel])
}

final class ListRickAndMortyViewController: UIViewController {
    private var interactor: ListRickAndMortyInteractorLogic?
    private(set) var router: ListRickAndMortyRouterLogic?
    
    private var dataTabel: [PersonTableViewCellModel] = []
    private var visibleCellCount = 0
    private var isLoadingMore = false
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Rick and Morty Persons"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)
          calculateVisibleCount()
      }

      override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          calculateVisibleCount()
      }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let viewController = self
        let presenter = ListRickAndMortyPresenter()
        let interactor = ListRickAndMortyInteractor()
        let router = ListRickAndMortyRouter()
        
        interactor.presenter = presenter
        presenter.viewController = viewController
        viewController.interactor = interactor
        router.viewController = viewController
        viewController.router = router
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        interactor?.downloadData(ids: Array(dataTabel.count..<dataTabel.count + 30))
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(PersonTableViewCell.self, forCellReuseIdentifier: PersonTableViewCell.identifier)
        tableView.rowHeight = 100
        setupConstraints()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationDidChange),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        
    }
    
    private func setupConstraints() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        portraitConstraints = [
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        
        landscapeConstraints = [
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(portraitConstraints)
    }
    
    @objc private func orientationDidChange() {
        updateTableForCurrentOrientation()
    }
    
    private func updateTableForCurrentOrientation() {
        let isLandscape = UIDevice.current.orientation.isLandscape
        
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        if isLandscape {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        } else if UIDevice.current.orientation.isPortrait {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        }
        tableView.reloadData()
    }
    
    private func calculateVisibleCount() {
        let adjustedHeight = tableView.bounds.height - tableView.adjustedContentInset.top - tableView.adjustedContentInset.bottom
        visibleCellCount = max(1, Int(adjustedHeight / 100))
    }
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension ListRickAndMortyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(dataTabel.count)
        return dataTabel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PersonTableViewCell.identifier, for: indexPath) as? PersonTableViewCell else { return UITableViewCell() }
        cell.configure(with: dataTabel[indexPath.row], delegate: self)
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if (offsetY > contentHeight - height - 100) && !isLoadingMore {
            isLoadingMore = true
            interactor?.downloadData(ids: Array(dataTabel.count..<dataTabel.count + visibleCellCount * 3))
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

//MARK: - ListRickAndMortyDisplayLogic
extension ListRickAndMortyViewController: ListRickAndMortyDisplayLogic {
    func displayData(persons: [PersonTableViewCellModel]) {
        let startIndex = dataTabel.count
        dataTabel += persons
        
        var indexPaths: [IndexPath] = []
        for i in 0..<persons.count {
            indexPaths.append(IndexPath(row: startIndex + i, section: 0))
        }
        
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: .bottom)
        tableView.endUpdates()
        
        isLoadingMore = false
    }
}

extension ListRickAndMortyViewController: PersonTableViewCellDelegate {
    func didTapPersonCell(withId id: Int) {
        print("gotk")
        router?.navigationToPersonDetails(id: id)
    }
}
