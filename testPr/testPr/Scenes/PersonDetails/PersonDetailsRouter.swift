import UIKit

protocol PersonDetailsRouterLogic: AnyObject {
}

protocol PersonDetailsDataPassing: AnyObject {
    var dataStore: PersonDetailsStoreInteractor? { get }
}

final class PersonDetailsRouter: PersonDetailsRouterLogic, PersonDetailsDataPassing {
    weak var dataStore: PersonDetailsStoreInteractor?
}
