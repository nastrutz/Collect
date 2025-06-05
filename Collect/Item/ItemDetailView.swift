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
    @State private var showingRenameAlert = false
    @State private var updatedItemName = ""

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
                
                Section(header: Text("Tags")) {
                    ForEach(Array(item.tags.enumerated()), id: \.offset) { index, _ in
                        HStack {
                            TextField("Tag", text: Binding(
                                get: {
                                    guard item.tags.indices.contains(index) else { return "" }
                                    return item.tags[index]
                                },
                                set: { newValue in
                                    if item.tags.indices.contains(index) {
                                        item.tags[index] = newValue
                                    }
                                }
                            ))
                            Spacer()
                            Button(action: {
                                if item.tags.indices.contains(index) {
                                    item.tags.remove(at: index)
                                }
                            }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    Button(action: {
                        item.tags.append("")
                    }) {
                        Label("Add Tag", systemImage: "plus.circle")
                    }
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    updatedItemName = item.name
                    showingRenameAlert = true
                } label: {
                    Image(systemName: "info.circle")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let snapshotImage = generateItemImage()
                    let activityVC = UIActivityViewController(activityItems: [snapshotImage], applicationActivities: nil)
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController {
                        rootVC.present(activityVC, animated: true)
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .alert("Rename Item", isPresented: $showingRenameAlert, actions: {
            TextField("Item Name", text: $updatedItemName)
            Button("Save", role: .none) {
                item.name = updatedItemName
            }
            Button("Cancel", role: .cancel) {}
        })
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

    func generateItemImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 320, height: 440))
        return renderer.image { context in
            let ctx = context.cgContext

            // Background
            ctx.setFillColor(UIColor.systemGray6.cgColor)
            ctx.fill(CGRect(x: 0, y: 0, width: 320, height: 440))

            // Header banner
            ctx.setFillColor(UIColor.systemBlue.cgColor)
            ctx.fill(CGRect(x: 0, y: 0, width: 320, height: 60))
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 22),
                .foregroundColor: UIColor.white,
                .paragraphStyle: {
                    let p = NSMutableParagraphStyle()
                    p.alignment = .center
                    return p
                }()
            ]
            let header = "Item Snapshot"
            header.draw(with: CGRect(x: 0, y: 15, width: 320, height: 30), options: .usesLineFragmentOrigin, attributes: headerAttributes, context: nil)

            // Image with border
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                let imageRect = CGRect(x: 60, y: 80, width: 200, height: 200)
                ctx.setStrokeColor(UIColor.systemGray.cgColor)
                ctx.setLineWidth(2)
                ctx.stroke(imageRect)
                uiImage.draw(in: imageRect)
            }

            // Text styling
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18),
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraphStyle
            ]

            let nameText = "Name: \(item.name)"
            nameText.draw(with: CGRect(x: 20, y: 300, width: 280, height: 30), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)

            let folderText = "Folder: \(item.folder?.name ?? "Unfiled")"
            folderText.draw(with: CGRect(x: 20, y: 340, width: 280, height: 30), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        }
    }
}
