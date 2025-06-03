//
//  ItemDetailView.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/3/25.
//


import SwiftUI

struct ItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let folders: [Folder]
    @Bindable var item: Item
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingFullImage = false

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
                        }
                        .labelsHidden()
                        .frame(maxWidth: 150)
                        .clipped()
                    }
                    .padding(.vertical, 4)
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
        .onChange(of: selectedImage) {
            if let selectedImage {
                item.imageData = selectedImage.jpegData(compressionQuality: 0.8)
            }
        }
    }
}
