//
//  ContentView.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/2/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var showingNamePrompt = false
    @State private var newItemName = ""
    @State private var selectedImage: UIImage?
    @State private var imagePickerPresented = false

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        ItemDetailView(item: item)
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Collect")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNamePrompt) {
                NavigationView {
                    VStack(spacing: 20) {
                        Text("Create Item")
                            .font(.title)
                            .bold()

                        TextField("Enter item name", text: $newItemName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 40)

                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .padding(.horizontal, 40)
                        }

                        Button("Select Image") {
                            imagePickerPresented = true
                        }

                        HStack(spacing: 40) {
                            Button("Cancel", role: .cancel) {
                                newItemName = ""
                                selectedImage = nil
                                showingNamePrompt = false
                            }
                            Button("Add") {
                                withAnimation {
                                    let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
                                    let newItem = Item(timestamp: Date(), name: newItemName, imageData: imageData)
                                    modelContext.insert(newItem)
                                    newItemName = ""
                                    selectedImage = nil
                                    showingNamePrompt = false
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
                    .sheet(isPresented: $imagePickerPresented) {
                        ImagePicker(image: $selectedImage)
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        showingNamePrompt = true
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
