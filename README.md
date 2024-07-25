# SwiftDataSwift6Concurrency

An iOS app test harness for exploring strict concurrency with SwiftData and Swift 6 async/await approach with modern macros. 

## Challenges

How to create a SwiftUI app where SwiftData operations run on background threads and eventually update SwiftUI views on the main actor as required - while dealing with cross actor boundary challenges.

### Crossing actor boundaries
This sample code approaches the problem with two solutions:

#### 1) PersistentIdentifier
Background actor sends SwiftData model IDs (`PersistentIdentifier`) to the main actor to be reconstituted in that context. 
In the SwiftData data service:

```swift
protocol DataServiceProtocol: ModelActor {
    associatedtype Model: PersistentModel
    associatedtype ViewModel: Sendable
    func fetchDataIds(predicate: Predicate<Model>?, sortBy: [SortDescriptor<Model>]) async throws -> [PersistentIdentifier]
}

extension DataServiceProtocol {
    func fetchDataIds(predicate: Predicate<Model>?, sortBy: [SortDescriptor<Model>]) async throws -> [PersistentIdentifier] {
        let fetchDescriptor = FetchDescriptor<Model>(predicate: predicate, sortBy: sortBy)
        let list: [Model] = try modelContext.fetch(fetchDescriptor)
        return list.map({ $0.id })
    }
}
```

Then in the viewModel class:
```swift
    private(set) var items: [Item] = []

    @MainActor
    func fetchDataByIds() async {
        guard let container = modelContext?.container else { return }
        let itemIds: [PersistentIdentifier] = await Task.detached {
            let dataService = DataService<Item>(modelContainer: container)
            if let itemIds: [PersistentIdentifier] = try? await dataService.fetchDataIds(predicate: nil, sortBy: [SortDescriptor(\.timestamp)]) {
                return itemIds
            }
            return []
        }.value
        
        let dbItems = itemIds.compactMap({ container.mainContext.model(for: $0) as? Item })
        self.items = dbItems // uncomment if using id approach for cross-boundary sending
    }
```

#### 2) Sendable Mirror object
Background actor sends `Sendable` objects mirroring the @Model classes.  

```swift

@Model final class Item { // fields }

@Observable final class ItemViewModel: Sendable, Identifiable, Hashable { // same field as Item } 

@ModelActor actor DataService<Model> where Model : PersistentModel {}

extension DataService: DataServiceProtocol {
    func fetchData(predicate: Predicate<Item>?, sortBy: [SortDescriptor<Item>]) async throws -> [ItemViewModel] {
        let fetchDescriptor = FetchDescriptor<Item>(predicate: predicate, sortBy: sortBy)
        let list: [Item] = try modelContext.fetch(fetchDescriptor)
        return list.map({ $0.viewModel })
    }
}
```

Then in the viewModel class:
```swift
    private(set) var items: [ItemViewModel] = []
    
    @MainActor
    func fetchData() async {
        guard let container = modelContext?.container else { return }
        let vmItems: [ItemViewModel] = await Task.detached {
            let dataService = DataService<Item>(modelContainer: container)
            if let items: [ItemViewModel] = try? await dataService.fetchData(predicate: nil, sortBy: [SortDescriptor(\.timestamp)]) {
                return items
            }
            return []
        }.value        
        self.items = vmItems
    }
```

## Install
- Build using Xcode 16 Beta and run. Uses Swift 6.

## Discussions
Feel free to ask questions and send feedback via issues tab.
