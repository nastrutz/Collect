//
//  ItemDetailView.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/3/25.
//


import SwiftUI

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var folders: [Folder] = []
    @Bindable var item: Item
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?

    var body: some View {
        Form {
            Section {
                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
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
                    }
                    .labelsHidden()
                    .frame(maxWidth: 150)
                    .clipped()
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(item.name)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .onChange(of: selectedImage) {
            if let selectedImage {
                item.imageData = selectedImage.jpegData(compressionQuality: 0.8)
            }
        }
    }
}
