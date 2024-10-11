//
//  Item.swift
//  SwiftData6TestHarness
//
//  Created by Paul Leo on 21/07/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    @Attribute(.unique) var messageId: String
    var timestamp: Date
    var message: String
    
    init(id: String = UUID().uuidString, message: String, timestamp: Date = Date.now) {
        self.messageId = id
        self.timestamp = timestamp
        self.message = message
    }
}

extension Item: ConvertablePersistentModelProtocol {
    var viewModel: ItemViewModel {
        return ItemViewModel(id: messageId, message: message, timestamp: timestamp)
    }
}

@MainActor
class PreviewController {
    static let previewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Item.self, configurations: config)
            
            for i in 1..<100 {
                let user = Item(id: "\(i)", message: "Message \(i)")
                container.mainContext.insert(user)
            }
            try? container.mainContext.save()
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
}

