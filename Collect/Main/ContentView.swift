//
//  ContentView.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/2/25.
//

import SwiftUI
import SwiftData
import LocalAuthentication
import Combine

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
    @AppStorage("themeRed") private var themeRed: Double = 0.0
    @AppStorage("themeGreen") private var themeGreen: Double = 0.478
    @AppStorage("themeBlue") private var themeBlue: Double = 1.0
    @AppStorage("hideBadgesManually") private var hideBadgesManually = false
    @AppStorage("hideBadgeList") private var hideBadgeList = false
    @State private var searchText = ""
    @StateObject private var badgeManager = BadgeManager()

    private var currentThemeColor: Color {
        Color(red: themeRed, green: themeGreen, blue: themeBlue)
    }

    private var filteredItems: [Item] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
    }

    private var filteredFolders: [Folder] {
        if searchText.isEmpty {
            return folders
        } else {
            return folders.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Group {
                    if !hideBadgeList {
                        Section(header: Text("Badges")) {
                            BadgeLabel(title: "5 Items", color: .gray, unlocked: badgeManager.badge5Unlocked)
                            BadgeLabel(title: "10 Items", color: .yellow, unlocked: badgeManager.badge10Unlocked)
                            BadgeLabel(title: "20 Items", color: .purple, unlocked: badgeManager.badge20Unlocked)
                        }
                    }
                }
                Section(header: Text("Unfiled items")) {
                    switch displayMode {
                    case .nameOnly:
                        ForEach(filteredItems) { item in
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
                        ForEach(filteredItems) { item in
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
                        ItemGridView(items: filteredItems)
                    }
                }

                FolderSectionView(
                    folders: filteredFolders,
                    modelContext: modelContext,
                    displayMode: displayMode,
                    folderToDelete: $folderToDelete,
                    showingDeleteAlert: $showingDeleteAlert,
                    path: $path
                )
            }
            .searchable(text: $searchText, prompt: "Search Collections")
            .navigationDestination(for: Folder.self) { folder in
                FolderDetailView(folder: folder, folders: folders)
            }
            .navigationDestination(for: Item.self) { item in
                ItemDetailView(folders: folders, item: item)
            }
            .navigationTitle("Collect")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ToolbarControlsView(displayMode: $displayMode, currentThemeColor: currentThemeColor, badgeManager: badgeManager, hideBadgesManually: hideBadgesManually)
                }
                ToolbarItem {
                    Button {
                        #if DEBUG
                        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                            showingSettings = true
                            return
                        }
                        #endif
                        authenticateForSettings()
                    } label: {
                        Image(systemName: "gear")
                    }
                    .foregroundColor(currentThemeColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("New Item", action: addItem)
                        Button("New Folder", action: addFolder)
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                    .tint(currentThemeColor)
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
                DispatchQueue.main.async {
                    showingSettings = success
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
