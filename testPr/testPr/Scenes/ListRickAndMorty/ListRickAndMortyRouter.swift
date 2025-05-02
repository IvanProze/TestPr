import UIKit

protocol ListRickAndMortyRouterLogic: AnyObject {
    func navigationToPersonDetails(id: Int)
}

final class ListRickAndMortyRouter: ListRickAndMortyRouterLogic {
    weak var viewController: UIViewController?
    
    func navigationToPersonDetails(id: Int) {
        let detailsVC = PersonDetailsViewController.assembleModule(personId: id)
        
        if let sheet = detailsVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
        
        viewController?.present(detailsVC, animated: true)
    }
    
}
