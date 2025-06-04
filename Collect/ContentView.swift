//
//  ContentView.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/2/25.
//

import SwiftUI
import SwiftData
import LocalAuthentication

enum DisplayMode: String, CaseIterable, Identifiable {
    case nameOnly = "Text"
    case nameAndImage = "Text + Image"
    case imageOnly = "Image Grid"
    var id: String { self.rawValue }
}

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
    @State private var folderToDelete: Folder?
    @State private var showingDeleteAlert = false
    @AppStorage("defaultDisplayMode") private var displayMode: DisplayMode = .nameAndImage
    @State private var folderImage: UIImage?
    @State private var folderImagePickerPresented = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section(header: Text("Unfiled items")) {
                    switch displayMode {
                    case .nameOnly:
                        ForEach(items) { item in
                            NavigationLink(value: item) {
                                Text(item.name)
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    modelContext.delete(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Menu {
                                    ForEach(folders) { folder in
                                        Button(folder.name) {
                                            item.folder = folder
                                            modelContext.insert(item)
                                        }
                                    }
                                } label: {
                                    Label("Change Folder", systemImage: "folder")
                                }
                            }
                        }
                        .onDelete(perform: deleteItems)

                    case .nameAndImage:
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
                            .contextMenu {
                                Menu {
                                    ForEach(folders) { folder in
                                        Button(folder.name) {
                                            item.folder = folder
                                            modelContext.insert(item)
                                        }
                                    }
                                } label: {
                                    Label("Change Folder", systemImage: "folder")
                                }
                                Button(role: .destructive) {
                                    modelContext.delete(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete(perform: deleteItems)

                    case .imageOnly:
                        ItemGridView(items: items)
                    }
                }

                FolderSectionView(
                    folders: folders,
                    modelContext: modelContext,
                    displayMode: displayMode,
                    folderToDelete: $folderToDelete,
                    showingDeleteAlert: $showingDeleteAlert,
                    path: $path
                )
            }
            .navigationDestination(for: Folder.self) { folder in
                FolderDetailView(folder: folder, folders: folders)
            }
            .navigationDestination(for: Item.self) { item in
                ItemDetailView(folders: folders, item: item)
            }
            .navigationTitle("Collect")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Picker("View", selection: $displayMode) {
                        ForEach(DisplayMode.allCases) { mode in
                            Image(systemName: {
                                switch mode {
                                case .nameOnly: return "line.3.horizontal"
                                case .nameAndImage: return "list.bullet"
                                case .imageOnly: return "square.grid.2x2"
                                }
                            }()).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                ToolbarItem {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("New Item", action: addItem)
                        Button("New Folder", action: addFolder)
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .alert("Delete Folder?", isPresented: $showingDeleteAlert, presenting: folderToDelete) { folder in
                Button("Delete", role: .destructive) {
                    modelContext.delete(folder)
                }
                Button("Cancel", role: .cancel) { }
            } message: { folder in
                Text("Deleting the folder \"\(folder.name)\" will also delete all items in it.")
            }
            .sheet(isPresented: $showingNamePrompt) {
                AddItemSheet(
                    newItemName: $newItemName,
                    selectedImage: $selectedImage,
                    selectedFolder: $selectedFolder,
                    imagePickerPresented: $imagePickerPresented,
                    folders: folders,
                    modelContext: modelContext,
                    dismiss: {
                        showingNamePrompt = false
                        newItemName = ""
                        selectedImage = nil
                        selectedFolder = nil
                    }
                )
            }
            .sheet(isPresented: $showingFolderPrompt) {
                AddFolderSheet(
                    newFolderName: $newFolderName,
                    folderImage: $folderImage,
                    folderImagePickerPresented: $folderImagePickerPresented,
                    modelContext: modelContext,
                    dismiss: {
                        newFolderName = ""
                        folderImage = nil
                        showingFolderPrompt = false
                    }
                )
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onChange(of: showingSettings) {
            #if DEBUG
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                return
            }
            #endif
            if showingSettings {
                authenticateForSettings()
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
    
    private func authenticateForSettings() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access settings") { success, _ in
                if !success {
                    DispatchQueue.main.async {
                        showingSettings = false
                    }
                }
            }
        } else {
            showingSettings = false
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Item.self, Folder.self], inMemory: true)
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("defaultDisplayMode") var defaultDisplayMode: DisplayMode = .nameAndImage
    @AppStorage("enableFolderLocking") var enableFolderLocking: Bool = true
    
    @State private var tempDisplayMode: DisplayMode
    @State private var tempEnableFolderLocking: Bool
    
    init() {
        let storedDisplayMode = UserDefaults.standard.string(forKey: "defaultDisplayMode")
        _tempDisplayMode = State(initialValue: DisplayMode(rawValue: storedDisplayMode ?? DisplayMode.nameAndImage.rawValue) ?? .nameAndImage)
        _tempEnableFolderLocking = State(initialValue: UserDefaults.standard.bool(forKey: "enableFolderLocking"))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("App Settings")) {
                    Picker("Default View Mode", selection: $tempDisplayMode) {
                        ForEach(DisplayMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }

                    Toggle("Enable Folder Locking", isOn: $tempEnableFolderLocking)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        UserDefaults.standard.set(tempDisplayMode.rawValue, forKey: "defaultDisplayMode")
                        UserDefaults.standard.set(tempEnableFolderLocking, forKey: "enableFolderLocking")
                        dismiss()
                    }
                }
            }
        }
    }
}
