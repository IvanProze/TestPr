import UIKit
import RickMortySwiftApi

protocol ListRickAndMortyPresentationLogic: AnyObject{
    func presentCharacters(persons: [RMCharacterModel]) async
}

@MainActor
final class ListRickAndMortyPresenter: ListRickAndMortyPresentationLogic {
    weak var viewController: ListRickAndMortyDisplayLogic?

    func presentCharacters(persons: [RMCharacterModel]) {
        let models = persons.map { model in
            let imageUrl = URL(string: model.image)
            return PersonTableViewCellModel(imageUrl: imageUrl, text: model.name, id: model.id)
        }
        viewController?.displayData(persons: models)
    }
}
