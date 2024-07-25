//
//  DataServiceTests.swift
//  SwiftData6TestHarness
//
//  Created by Paul Leo on 25/07/2024.
//

import Testing
@testable import SwiftData6TestHarness
import SwiftData
import Foundation

struct DataServiceTests {

    @MainActor @Test func fetchDataTest() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        
        let count = 100
        for i in 0..<count {
            let user = Item(id: "\(i)", message: "Message \(i)")
            container.mainContext.insert(user)
        }
        try? container.mainContext.save()
        let sut = DataService<Item>(modelContainer: container)
        do {
            let items = try await sut.fetchData(predicate: nil, sortBy: [SortDescriptor(\.timestamp)])
            #expect(items.count == count)
        } catch {
            assertionFailure("Fetch error thrown")
        }
    }

    @MainActor @Test func removeIdTest() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        
        let user = Item(id: "\(1)", message: "Message \(1)")
        container.mainContext.insert(user)
        try? container.mainContext.save()
        let sut = DataService<Item>(modelContainer: container)
        do {
            await sut.remove(id: user.id)
            let items = try await sut.fetchData(predicate: nil, sortBy: [SortDescriptor(\.timestamp)])
            #expect(items.isEmpty)
        } catch {
            assertionFailure("Fetch error thrown")
        }
    }
    
    @MainActor @Test func removePredicateTest() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        
        let user = Item(id: "\(1)", message: "Message \(1)")
        container.mainContext.insert(user)
        try? container.mainContext.save()
        let sut = DataService<Item>(modelContainer: container)
        do {
            let t = user.timestamp
            try await sut.remove(predicate: #Predicate{ $0.timestamp == t })
            let items = try await sut.fetchData(predicate: nil, sortBy: [SortDescriptor(\.timestamp)])
            #expect(items.isEmpty)
        } catch {
            assertionFailure("Fetch error thrown")
        }
    }
    
    @MainActor @Test func insertTest() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)

        let sut = DataService<Item>(modelContainer: container)
        do {
            let date = Date.now
            await sut.insert(data: ItemViewModel(message: "Hello World"))
            let items = try await sut.fetchData(predicate: nil, sortBy: [SortDescriptor(\.timestamp)])
            #expect(items.count == 1)
            #expect(items.first?.timestamp == date)
        } catch {
            assertionFailure("Fetch error thrown")
        }
    }
}
