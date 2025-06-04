//
//  AddFolderSheet.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/3/25.
//

import SwiftUI
import SwiftData

struct AddFolderSheet: View {
    @Binding var newFolderName: String
    @Binding var folderImage: UIImage?
    @Binding var folderImagePickerPresented: Bool
    let modelContext: ModelContext
    let dismiss: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create Folder")
                    .font(.title)
                    .bold()

                Button("Add or Change Image") {
                    folderImagePickerPresented = true
                }

                if let folderImage = folderImage {
                    Image(uiImage: folderImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                TextField("Enter folder name", text: $newFolderName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 40)

                HStack(spacing: 40) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                    Button("Add") {
                        withAnimation {
                            let newFolder = Folder(name: newFolderName)
                            newFolder.imageData = folderImage?.jpegData(compressionQuality: 0.8)
                            modelContext.insert(newFolder)
                            dismiss()
                        }
                    }
                    .disabled(newFolderName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
            .padding()
        }
        .sheet(isPresented: $folderImagePickerPresented) {
            ImagePicker(image: $folderImage)
        }
    }
}
