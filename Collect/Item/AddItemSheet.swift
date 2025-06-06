//
//  AddItemSheet.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/3/25.
//

import SwiftUI
import SwiftData
import Foundation

struct AddItemSheet: View {
    @AppStorage("themeRed") private var themeRed: Double = 0.0
    @AppStorage("themeGreen") private var themeGreen: Double = 0.478
    @AppStorage("themeBlue") private var themeBlue: Double = 1.0

    @Binding var newItemName: String
    @Binding var selectedImage: UIImage?
    @Binding var selectedFolder: Folder?
    @Binding var imagePickerPresented: Bool
    let folders: [Folder]
    let modelContext: ModelContext
    let dismiss: () -> Void

    @State private var showFolderSuggestion = false
    @State private var suggestedFolder: Folder? = nil
    @AppStorage("disableSuggestedFolders") private var disableSuggestedFolders: Bool = false
    @State private var tagInput: String = ""
    @State private var tagInputTags: [String] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create Item")
                    .font(.title)
                    .bold()

                TextField("Enter item name", text: $newItemName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 40)

                TagInputView(tagInput: $tagInput, tagInputTags: $tagInputTags)

                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .padding(.horizontal, 40)
                }

                Button {
                    imagePickerPresented = true
                } label: {
                    Text("Select Image")
                        .foregroundColor(Color(red: themeRed, green: themeGreen, blue: themeBlue))
                }

                Picker("Select Folder", selection: $selectedFolder) {
                    Text("Unfiled").tag(nil as Folder?)
                    ForEach(folders, id: \.self) { folder in
                        Text(folder.name).tag(Optional(folder))
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal, 40)
                .tint(Color(red: themeRed, green: themeGreen, blue: themeBlue))

                HStack(spacing: 40) {
                    Button(role: .cancel) {
                        resetAndDismiss()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(Color(red: themeRed, green: themeGreen, blue: themeBlue))
                    }
                    Button {
                        withAnimation {
                            let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
                            let tagsArray = tagInputTags
                            let newItem = Item(timestamp: Date(), name: newItemName, imageData: imageData, tags: tagsArray)

                            if let folder = selectedFolder {
                                folder.items.append(newItem)
                                print("Total items collected: \(BadgeManager.shared.totalItemsCollected + 1)")
                                BadgeManager.shared.incrementBadgeItems()
                                resetAndDismiss()
                            } else if !disableSuggestedFolders {
                                let lowercasedItemName = newItemName.lowercased()
                                if let matchingFolder = folders.first(where: { folder in
                                    folder.name.lowercased().split(separator: " ").contains(where: { lowercasedItemName.contains($0) })
                                }) {
                                    DispatchQueue.main.async {
                                        suggestedFolder = matchingFolder
                                        showFolderSuggestion = true
                                        return
                                    }
                                } else {
                                    modelContext.insert(newItem)
                                    print("Total items collected: \(BadgeManager.shared.totalItemsCollected + 1)")
                                    BadgeManager.shared.incrementBadgeItems()
                                    resetAndDismiss()
                                }
                            } else {
                                modelContext.insert(newItem)
                                print("Total items collected: \(BadgeManager.shared.totalItemsCollected + 1)")
                                BadgeManager.shared.incrementBadgeItems()
                                resetAndDismiss()
                            }
                        }
                    } label: {
                        Text("Add")
                            .foregroundColor(Color(red: themeRed, green: themeGreen, blue: themeBlue))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
            .sheet(isPresented: $imagePickerPresented) {
                ImagePicker(image: $selectedImage)
            }
            .alert("Suggested Folder", isPresented: $showFolderSuggestion) {
                Button("Yes") {
                    let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
                    let tagsArray = tagInputTags
                    if let folder = suggestedFolder {
                        let newItem = Item(timestamp: Date(), name: newItemName, imageData: imageData, tags: tagsArray)
                        folder.items.append(newItem)
                        print("Total items collected: \(BadgeManager.shared.totalItemsCollected + 1)")
                        BadgeManager.shared.incrementBadgeItems()
                    } else {
                        let newItem = Item(timestamp: Date(), name: newItemName, imageData: imageData, tags: tagsArray)
                        modelContext.insert(newItem)
                        print("Total items collected: \(BadgeManager.shared.totalItemsCollected + 1)")
                        BadgeManager.shared.incrementBadgeItems()
                    }
                    resetAndDismiss()
                }
                Button("No", role: .cancel) {
                    let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
                    let tagsArray = tagInputTags
                    let newItem = Item(timestamp: Date(), name: newItemName, imageData: imageData, tags: tagsArray)
                    modelContext.insert(newItem)
                    print("Total items collected: \(BadgeManager.shared.totalItemsCollected + 1)")
                    BadgeManager.shared.incrementBadgeItems()
                    resetAndDismiss()
                }
            } message: {
                Text("The item name contains a word matching the folder '\(suggestedFolder?.name ?? "")'. Do you want to add it there?")
            }
        }
    }

    private func resetAndDismiss() {
        newItemName = ""
        selectedImage = nil
        selectedFolder = nil
        tagInputTags = []
        dismiss()
    }
}
