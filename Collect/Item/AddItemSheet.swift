//
//  AddItemSheet.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/3/25.
//

import SwiftUI
import SwiftData

struct AddItemSheet: View {
    @Binding var newItemName: String
    @Binding var selectedImage: UIImage?
    @Binding var selectedFolder: Folder?
    @Binding var imagePickerPresented: Bool
    let folders: [Folder]
    let modelContext: ModelContext
    let dismiss: () -> Void

    @State private var showFolderSuggestion = false
    @State private var suggestedFolder: Folder? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create Item")
                    .font(.title)
                    .bold()

                TextField("Enter item name", text: $newItemName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 40)

                if let selectedImage {
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
                        resetAndDismiss()
                    }
                    Button("Add") {
                        withAnimation {
                            let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
                            let newItem = Item(timestamp: Date(), name: newItemName, imageData: imageData)

                            if selectedFolder != nil {
                                selectedFolder!.items.append(newItem)
                                resetAndDismiss()
                            } else {
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
                                    resetAndDismiss()
                                }
                            }
                        }
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
                    if let folder = suggestedFolder {
                        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
                        let newItem = Item(timestamp: Date(), name: newItemName, imageData: imageData)
                        folder.items.append(newItem)
                    } else {
                        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
                        let newItem = Item(timestamp: Date(), name: newItemName, imageData: imageData)
                        modelContext.insert(newItem)
                    }
                    resetAndDismiss()
                }
                Button("No", role: .cancel) {
                    let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
                    let newItem = Item(timestamp: Date(), name: newItemName, imageData: imageData)
                    modelContext.insert(newItem)
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
        dismiss()
    }
}
