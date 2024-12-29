//
//  ItemViewModel.swift
//  SwiftData6TestHarness
//
//  Created by Paul Leo on 25/07/2024.
//

import Foundation

extension Item {
    struct Sender: Sendable, Identifiable, Hashable, ConvertableViewModelProtocol {
        let messageId: String
        let message: String
        let timestamp: Date
        
        init(id: String = UUID().uuidString, message: String, timestamp: Date = Date.now) {
            self.messageId = id
            self.message = message
            self.timestamp = timestamp
        }

        var id: String {
            return messageId
        }
        
        static func == (lhs: Sender, rhs: Sender) -> Bool {
            return lhs.messageId == rhs.messageId
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(messageId)
            hasher.combine(message)
            hasher.combine(timestamp)
        }

        var model: Item {
            let data = Item(id: messageId, message: message, timestamp: timestamp)
            return data
        }
    }
}


