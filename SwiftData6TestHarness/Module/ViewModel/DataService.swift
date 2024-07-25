//
//  DataService.swift
//  OpenCV
//
//  Created by Paul Leo on 18/07/2024.
//

import Foundation
import SwiftData

protocol DataServiceProtocol: ModelActor {
    associatedtype Model: PersistentModel
    associatedtype ViewModel: Sendable
    func fetchDataIds(predicate: Predicate<Model>?, sortBy: [SortDescriptor<Model>]) async throws -> [PersistentIdentifier]
    func save() async throws
    func remove(predicate: Predicate<Model>?) async throws
    func remove(id: PersistentIdentifier) async
    
    func fetchData(predicate: Predicate<Model>?, sortBy: [SortDescriptor<Model>]) async throws -> [ViewModel]
    func insert(data: ViewModel) async
}

extension DataServiceProtocol {
    func fetchDataIds(predicate: Predicate<Model>?, sortBy: [SortDescriptor<Model>]) async throws -> [PersistentIdentifier] {
        let fetchDescriptor = FetchDescriptor<Model>(predicate: predicate, sortBy: sortBy)
        let list: [Model] = try modelContext.fetch(fetchDescriptor)
        return list.map({ $0.id })
    }

    func fetchCount(predicate: Predicate<Model>? = nil, sortBy: [SortDescriptor<Model>] = []) async throws -> Int {
        let fetchDescriptor = FetchDescriptor<Model>(predicate: predicate, sortBy: sortBy)
        let count = try modelContext.fetchCount(fetchDescriptor)
        return count
    }

    func save() async throws {
        try modelContext.save()
    }

    func remove(predicate: Predicate<Model>? = nil) async throws {
        try modelContext.delete(model: Model.self, where: predicate)
        try await save()
    }
    
    func remove(id: PersistentIdentifier) async {
        if let item = modelContext.model(for: id) as? Model {
            modelContext.delete(item)
        }
        try? modelContext.save()
    }

    func saveAndInsertIfNeeded(data: Model, predicate: Predicate<Model>) async throws {
        let descriptor = FetchDescriptor<Model>(predicate: predicate)
        let savedCount = try modelContext.fetchCount(descriptor)

        if savedCount == 0 {
            modelContext.insert(data)
        }
        try await save()
    }
}

/// ```swift
///  // It is important that this actor works as a mutex,
///  // so you must have one instance of the Actor for one container
//   // for it to work correctly.
///  let actor = BackgroundSerialPersistenceActor(container: modelContainer)
///
///  Task {
///      let data: [MyModel] = try? await actor.fetchData()
///  }
///  ```
@available(iOS 17, *)
@ModelActor
actor DataService<Model> where Model : PersistentModel {}

extension DataService: DataServiceProtocol {
    func fetchData(predicate: Predicate<Item>?, sortBy: [SortDescriptor<Item>]) async throws -> [ItemViewModel] {
        let fetchDescriptor = FetchDescriptor<Item>(predicate: predicate, sortBy: sortBy)
        let list: [Item] = try modelContext.fetch(fetchDescriptor)
        return list.map({ $0.viewModel })
    }
    
    func insert(data: ItemViewModel) async {
        let data = Item(id: data.messageId, message: data.message, timestamp: data.timestamp)
        modelContext.insert(data)
        try? modelContext.save()
    }
}
