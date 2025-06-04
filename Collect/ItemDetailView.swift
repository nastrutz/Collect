//
//  ItemDetailView.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/3/25.
//


import SwiftUI

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let folders: [Folder]
    @Bindable var item: Item
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingFullImage = false
    @State private var showingFolderPrompt = false
    @State private var newFolderName = ""
    @State private var folderImage: UIImage?
    @State private var folderImagePickerPresented = false

    var body: some View {
        ZStack {
            Form {
                Section {
                    if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                        HStack {
                            Spacer()
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 200, height: 200)
                                .onTapGesture {
                                    showingFullImage = true
                                }
                            Spacer()
                        }
                    }
                    Button("Add or Change Image") {
                        showingImagePicker = true
                    }
                }

                Section {
                    HStack {
                        Text("Folder:")
                            .font(.subheadline)
                        Spacer()
                        Picker("", selection: $item.folder) {
                            Text("Unfiled").tag(nil as Folder?)
                            ForEach(folders, id: \.self) { folder in
                                Text(folder.name).tag(Optional(folder))
                            }
                            Text("New Folder…").tag(Folder?.some(Folder(name: "__new__")))
                        }
                        .labelsHidden()
                        .frame(maxWidth: 150)
                        .clipped()
                        .onChange(of: item.folder) { oldValue, newValue in
                            if let newValue, newValue.name == "__new__" {
                                showingFolderPrompt = true
                                item.folder = nil
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section {
                    Button(role: .destructive) {
                        modelContext.delete(item)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Item")
                            Spacer()
                        }
                    }
                }
            }

            // Overlay full image
            if showingFullImage, let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .onTapGesture {
                            showingFullImage = false
                        }
                    Spacer()
                }
                .transition(.opacity)
            }
        }
        .navigationTitle(item.name)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .sheet(isPresented: $showingFolderPrompt) {
            AddFolderSheet(
                newFolderName: $newFolderName,
                folderImage: $folderImage,
                folderImagePickerPresented: $folderImagePickerPresented,
                modelContext: modelContext,
                dismiss: {
                    showingFolderPrompt = false
                    newFolderName = ""
                    folderImage = nil
                }
            )
        }
        .onChange(of: selectedImage) {
            if let selectedImage {
                item.imageData = selectedImage.jpegData(compressionQuality: 0.8)
            }
        }
    }
}
