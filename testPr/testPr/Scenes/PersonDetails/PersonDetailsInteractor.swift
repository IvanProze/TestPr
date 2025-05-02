import Foundation

protocol PersonDetailsInteractorLogic: AnyObject {
    func downloadData()
}

protocol PersonDetailsStoreInteractor: AnyObject {
    var personId: Int {get set}
}

final class PersonDetailsInteractor: PersonDetailsStoreInteractor {
    var personId: Int = -1
    var presenter: PersonDetailsPresentationLogic?
}

extension PersonDetailsInteractor: PersonDetailsInteractorLogic {
    func downloadData() {
        Task {
            let person = MemoryManager.shared.files.first(where: {$0.id == personId})
            await presenter?.presentCharacters(person: person )
        }
    }
}

