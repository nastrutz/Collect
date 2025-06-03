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
    @Query(filter: #Predicate<Item> { item in
        item.folder == nil
    }) private var items: [Item]
    @Query private var folders: [Folder]
    @State private var showingNamePrompt = false
    @State private var newItemName = ""
    @State private var selectedImage: UIImage?
    @State private var imagePickerPresented = false
    @State private var showingFolderPrompt = false
    @State private var newFolderName = ""
    @State private var selectedFolder: Folder?
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section(header: Text("Unfiled items")) {
                    ForEach(items) { item in
                        NavigationLink(value: item) {
                            HStack {
                                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                Text(item.name)
                                    .font(.body)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }

                Section(header: Text("Folders")) {
                    ForEach(folders) { folder in
                        NavigationLink(value: folder) {
                            Text(folder.name)
                        }
                    }
                }
            }
            .navigationDestination(for: Folder.self) { folder in
                FolderDetailView(folder: folder)
            }
            .navigationDestination(for: Item.self) { item in
                ItemDetailView(item: item)
            }
            .navigationTitle("Collect")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Menu {
                        Button("New Item", action: addItem)
                        Button("New Folder", action: addFolder)
                    } label: {
                        Label("Add", systemImage: "plus")
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

                        Picker("Select Folder", selection: $selectedFolder) {
                            Text("Unfiled").tag(nil as Folder?)
                            ForEach(folders, id: \.self) { folder in
                                Text(folder.name).tag(Optional(folder))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.horizontal, 40)

                        HStack(spacing: 40) {
                            Button("Cancel", role: .cancel) {
                                newItemName = ""
                                selectedImage = nil
                                selectedFolder = nil
                                showingNamePrompt = false
                            }
                            Button("Add") {
                                withAnimation {
                                    let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
                                    let newItem = Item(timestamp: Date(), name: newItemName, imageData: imageData)
                                    if let folder = selectedFolder {
                                        folder.items.append(newItem)
                                    } else {
                                        modelContext.insert(newItem)
                                    }
                                    newItemName = ""
                                    selectedImage = nil
                                    selectedFolder = nil
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
        }
        .sheet(isPresented: $showingFolderPrompt) {
            NavigationView {
                VStack(spacing: 20) {
                    Text("Create Folder")
                        .font(.title)
                        .bold()

                    TextField("Enter folder name", text: $newFolderName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 40)

                    HStack(spacing: 40) {
                        Button("Cancel", role: .cancel) {
                            newFolderName = ""
                            showingFolderPrompt = false
                        }
                        Button("Add") {
                            withAnimation {
                                let newFolder = Folder(name: newFolderName, items: [])
                                modelContext.insert(newFolder)
                                newFolderName = ""
                                showingFolderPrompt = false
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .multilineTextAlignment(.center)
            }
        }
    }

    private func addItem() {
        showingNamePrompt = true
    }

    private func addFolder() {
        showingFolderPrompt = true
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
        .modelContainer(for: [Item.self, Folder.self], inMemory: true)
}
