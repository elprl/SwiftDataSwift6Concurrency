//
//  SwiftData6TestHarnessTests.swift
//  SwiftData6TestHarnessTests
//
//  Created by Paul Leo on 21/07/2024.
//

import Testing
@testable import SwiftData6TestHarness
import SwiftData
import Foundation

struct ViewModelTests {

    @MainActor @Test func fetchTest() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        
        let count = 100
        for i in 0..<count {
            let user = Item(id: "\(i)", message: "Message \(i)")
            container.mainContext.insert(user)
        }
        try? container.mainContext.save()
        let sut = ContentViewModel(modelContext: container.mainContext)
        await sut.fetchData()

        #expect(sut.items.count == count)
    }

    @MainActor @Test func deleteTest() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        
        let user = Item(id: "\(1)", message: "Message \(1)")
        container.mainContext.insert(user)
        try? container.mainContext.save()
        let sut = ContentViewModel(modelContext: container.mainContext)
        await sut.fetchData()
        await sut.deleteItems(offsets: IndexSet(integer: 0))

        #expect(sut.items.isEmpty)
    }
    
    @MainActor @Test func insertTest() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)

        let sut = ContentViewModel(modelContext: container.mainContext)
        let date = Date.now
        await sut.addItem(message: "Message 1")

        #expect(sut.items.count == 1)
        #expect(sut.items.first?.timestamp == date)
    }
}
