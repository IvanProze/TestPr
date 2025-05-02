import Foundation
import UIKit
import RickMortySwiftApi

final class MemoryManager {
    static let shared = MemoryManager()
    private let client = RMClient()
    private let fileManager = FileManager.default
    private let cacheDir: URL
    private let maxCacheAge: TimeInterval = 60 * 60 * 24 * 7 // 7 days

    private let filesKey = "TestPr.RMCharacterModels"

    var files: [RMCharacterModel] {
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: filesKey)
        }
        get {
            guard let data = UserDefaults.standard.data(forKey: filesKey) else {
                return []
            }
            return (try? JSONDecoder().decode([RMCharacterModel].self, from: data)) ?? []
        }
    }

    private init() {
        cacheDir = try! fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppTermination),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleAppTermination() {
        UserDefaults.standard.removeObject(forKey: filesKey)
    }

    func fetchCharacterDetails(ids: [Int]) async -> [RMCharacterModel]? {
        guard !ids.isEmpty else { return [] }
        
        var cachedCharacters: [RMCharacterModel] = []
        var idsToFetch: [Int] = []
        
        for id in ids {
            if let character = await loadFromCache(id: id) {
                cachedCharacters.append(character)
            } else {
                idsToFetch.append(id)
            }
        }
        
        if !idsToFetch.isEmpty {
            do {
                let fetched = try await client.character().getCharactersByIDs(ids: idsToFetch)
                for character in fetched {
                    await saveToCache(character: character)
                }
                let all = cachedCharacters + fetched
                return all.sorted { $0.id < $1.id }
            } catch {
                print("Error fetching characters: \(error)")
                return cachedCharacters.isEmpty ? nil : cachedCharacters.sorted { $0.id < $1.id }
            }
        } else {
            return cachedCharacters.sorted { $0.id < $1.id }
        }
    }

    private func loadFromCache(id: Int) async -> RMCharacterModel? {
        let cacheURL = cacheDir.appendingPathComponent("character_\(id).json")
        guard fileManager.fileExists(atPath: cacheURL.path) else { return nil }
        
        do {
            let attrs = try fileManager.attributesOfItem(atPath: cacheURL.path)
            if let modDate = attrs[.modificationDate] as? Date,
               Date().timeIntervalSince(modDate) > maxCacheAge {
                return nil
            }
            let data = try Data(contentsOf: cacheURL)
            return try JSONDecoder().decode(RMCharacterModel.self, from: data)
        } catch {
            print("Error loading from cache: \(error)")
            return nil
        }
    }

    private func saveToCache(character: RMCharacterModel) async {
        let cacheURL = cacheDir.appendingPathComponent("character_\(character.id).json")
        do {
            let data = try JSONEncoder().encode(character)
            try data.write(to: cacheURL, options: .atomic)
        } catch {
            print("Error saving to cache: \(error)")
        }
    }

    func clearOldCacheEntries() {
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheDir,
                                                              includingPropertiesForKeys: [.contentModificationDateKey])
            let cutoff = Date().addingTimeInterval(-maxCacheAge)
            for url in contents {
                if let attrs = try? fileManager.attributesOfItem(atPath: url.path),
                   let modDate = attrs[.modificationDate] as? Date,
                   modDate < cutoff {
                    try? fileManager.removeItem(at: url)
                }
            }
        } catch {
            print("Error clearing cache: \(error)")
        }
    }
}
