//
//  AddFolderSheet.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/3/25.
//

import SwiftUI
import SwiftData
import LocalAuthentication

struct AddFolderSheet: View {
    @AppStorage("themeRed") private var themeRed: Double = 0.0
    @AppStorage("themeGreen") private var themeGreen: Double = 0.478
    @AppStorage("themeBlue") private var themeBlue: Double = 1.0

    @Binding var newFolderName: String
    @Binding var folderImage: UIImage?
    @Binding var folderImagePickerPresented: Bool
    let modelContext: ModelContext
    let dismiss: () -> Void

    @State private var useFaceID = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create Folder")
                    .font(.title)
                    .bold()

                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    folderImagePickerPresented = true
                } label: {
                    Text("Select Image")
                        .foregroundColor(Color(red: themeRed, green: themeGreen, blue: themeBlue))
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

                Toggle("Lock with Face ID", isOn: $useFaceID)
                    .padding(.horizontal, 40)
                    .tint(
                        (themeRed == 0.0 && themeGreen == 0.478 && themeBlue == 1.0)
                        ? .green
                        : Color(red: themeRed, green: themeGreen, blue: themeBlue)
                    )

                HStack(spacing: 40) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(Color(red: themeRed, green: themeGreen, blue: themeBlue))
                    }
                    Button {
                        withAnimation {
                            let newFolder = Folder(name: newFolderName)
                            newFolder.imageData = folderImage?.jpegData(compressionQuality: 0.8)
                            newFolder.isLocked = useFaceID
                            modelContext.insert(newFolder)
                            dismiss()
                        }
                    } label: {
                        Text("Add")
                            .foregroundColor(Color(red: themeRed, green: themeGreen, blue: themeBlue))
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
