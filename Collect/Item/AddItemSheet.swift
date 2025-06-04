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
                            if let folder = selectedFolder {
                                folder.items.append(newItem)
                            } else {
                                modelContext.insert(newItem)
                            }
                            resetAndDismiss()
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

    private func resetAndDismiss() {
        newItemName = ""
        selectedImage = nil
        selectedFolder = nil
        dismiss()
    }
}
