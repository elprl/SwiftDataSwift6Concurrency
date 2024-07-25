//
//  ItemViewModel.swift
//  SwiftData6TestHarness
//
//  Created by Paul Leo on 25/07/2024.
//

import Foundation

@Observable
final class ItemViewModel: Sendable, Identifiable, Hashable {
    let messageId: String
    let message: String
    let timestamp: Date

    init(id: String = UUID().uuidString, message: String, timestamp: Date = Date.now) {
        self.messageId = id
        self.message = message
        self.timestamp = timestamp
    }
    
    static func == (lhs: ItemViewModel, rhs: ItemViewModel) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(messageId)
        hasher.combine(message)
        hasher.combine(timestamp)
    }
}
