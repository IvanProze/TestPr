import UIKit
import RickMortySwiftApi

protocol PersonDetailsPresentationLogic: AnyObject{
    func presentCharacters(person: RMCharacterModel?) async
}

@MainActor
final class PersonDetailsPresenter: PersonDetailsPresentationLogic {
    weak var viewController: PersonDetailsDisplayLogic?

    func presentCharacters(person: RMCharacterModel?) {
        guard let person = person else { return }

        let imageUrl = URL(string: person.image)

        let description = """
        Статус: \(person.status)
        Вид: \(person.species)
        Стать: \(person.gender)
        Походження: \(person.origin.name)
        Поточне місце: \(person.location.name)
        """

        let model = PersonDetailsModels(
            imageUrl: imageUrl,
            text: description,
            name: person.name
        )

        viewController?.displayData(persons: model)
    }
}
