//
//  ContentView.swift
//  SwiftData6TestHarness
//
//  Created by Paul Leo on 21/07/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var viewModel: ContentViewModel
    
    init(modelContext: ModelContext) {
        _viewModel = State(initialValue: ContentViewModel(modelContext: modelContext))
        
    }

#if DEBUG
    init(viewModel: ContentViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
#endif
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(viewModel.items) { item in
                    NavigationLink {
                        Text(item.message)
                    } label: {
                        VStack {
                            Text(item.message)
                                .font(.body)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .transition(.slide)
                    .id(item.messageId)
                }
                .onDelete(perform: deleteItems)
            }
            .id("List")
            .animation(.default, value: viewModel.items)
            .task {
                Task {
                    await viewModel.fetchData()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: {
                        Task {
                            await viewModel.addItem(message: "Message added \(Date.now)" )
                        }
                    }) {
                        Label("Add Item", systemImage: "plus")
                    }
                    .id("Add")
                }
                ToolbarItem {
                    Button(action: {
                        Task {
                            await viewModel.fetchData()
                        }
                    }) {
                        Label("refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        Task {
            await viewModel.deleteItems(offsets: offsets)
        }
    }
}

// use when viewModel.items is [Item]
#Preview {
    ContentView(modelContext: PreviewController.previewContainer.mainContext)
        .modelContainer(for: Item.self, inMemory: true)
}

#if DEBUG
// use when viewModel.items is [ItemViewModel]
#Preview {
    ContentView(viewModel: PreviewVMController.previewContainer)
}

@MainActor
class PreviewVMController {
    static let previewContainer: ContentViewModel = {
        var vm = ContentViewModel(modelContext: nil)
        vm.items = [ItemViewModel(id: UUID().uuidString, message: "Hello world", timestamp: Date.now)]
        return vm
    }()
}
#endif
