//
//  ViewTests.swift
//  SwiftData6TestHarness
//
//  Created by Paul Leo on 25/07/2024.
//

import Testing
@testable import SwiftData6TestHarness
import SwiftData
import Foundation
import ViewInspector
import SwiftUI

struct ViewTests {
    
    @MainActor @Test func listTest() async throws {
        let viewModel = ContentViewModel(modelContext: nil)
        let text = "Hello world"
        viewModel.items = [ItemViewModel(message: text)]

        let sut = ContentView(viewModel: viewModel)

        do {
            let textLabel = try sut.inspect().find(text: text)
            let string = try textLabel.string()
            #expect(string == text)
        } catch {
            #expect(error == nil)
        }
    }
}
