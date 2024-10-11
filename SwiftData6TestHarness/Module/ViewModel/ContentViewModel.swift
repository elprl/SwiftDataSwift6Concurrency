//
//  ContentViewModel.swift
//  SwiftData6TestHarness
//
//  Created by Paul Leo on 21/07/2024.
//

import Combine
import SwiftData
import SwiftUI

@Observable
final class ContentViewModel {
    var items: [ItemViewModel] = [] // if using vm objects approach for cross-boundary sending
//    private(set) var items: [Item] = [] // if using ids approach for cross-boundary sending
    @ObservationIgnored private let modelContext: ModelContext?
    
    /// pass nil for previews or unit testing
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    @MainActor
    func addItem(message: String) async {
        guard let container = modelContext?.container else { return }
        let task = Task.detached {
            let dataService = DataService<Item, ItemViewModel>(modelContainer: container)
            await dataService.insert(data: ItemViewModel(id: UUID().uuidString, message: message, timestamp: Date.now))
        }
        await task.value
        await fetchData()
    }
    
    @MainActor
    func deleteItems(offsets: IndexSet) async {
        guard let container = modelContext?.container else { return }
        let delItems = offsets.compactMap({ items[safe: $0] })
        let task = Task.detached {
            let dataService = DataService<Item, ItemViewModel>(modelContainer: container)
            do {
                for item in delItems {
                    let t = item.timestamp
                    try await dataService.remove(predicate: #Predicate<Item> { $0.timestamp == t } )
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        await task.value
        await fetchData()
    }
    
    @MainActor
    func fetchDataByIds() async {
        guard let container = modelContext?.container else { return }
        let itemIds: [PersistentIdentifier] = await Task.detached {
            let dataService = DataService<Item, ItemViewModel>(modelContainer: container)
            if let itemIds: [PersistentIdentifier] = try? await dataService.fetchDataIds(predicate: nil, sortBy: [SortDescriptor(\.timestamp)]) {
                return itemIds
            }
            return []
        }.value
        
        let dbItems = itemIds.compactMap({ container.mainContext.model(for: $0) as? Item })
//        self.items = dbItems // uncomment if using id approach for cross-boundary sending
    }
    
    
    @MainActor
    func fetchData() async {
        guard let container = modelContext?.container else { return }
        let vmItems: [ItemViewModel] = await Task.detached {
            let dataService = DataService<Item, ItemViewModel>(modelContainer: container)
            if let items: [ItemViewModel] = try? await dataService.fetchDataVMs(predicate: nil, sortBy: [SortDescriptor(\.timestamp)]) {
                return items
            }
            return []
        }.value        
        self.items = vmItems
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
