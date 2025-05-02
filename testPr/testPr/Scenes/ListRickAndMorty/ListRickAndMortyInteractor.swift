import Foundation

protocol ListRickAndMortyInteractorLogic: AnyObject {
    func downloadData(ids: [Int])
}

final class ListRickAndMortyInteractor {
    var presenter: ListRickAndMortyPresentationLogic?
}

extension ListRickAndMortyInteractor: ListRickAndMortyInteractorLogic {
    func downloadData(ids: [Int]) {
        Task {
            let allPersons =  await MemoryManager.shared.fetchCharacterDetails(ids: ids)
            MemoryManager.shared.files = allPersons ?? []
            await presenter?.presentCharacters(persons: MemoryManager.shared.files )
        }
    }
}
