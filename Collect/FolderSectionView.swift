//
//  FolderSectionView.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/3/25.
//


import SwiftUI
import SwiftData

struct FolderSectionView: View {
    let folders: [Folder]
    let modelContext: ModelContext
    let displayMode: DisplayMode
    @Binding var folderToDelete: Folder?
    @Binding var showingDeleteAlert: Bool
    @Binding var path: NavigationPath

    var body: some View {
        Section(header: Text("Folders")) {
            ForEach(folders) { folder in
                NavigationLink(value: folder) {
                    HStack {
                        if displayMode != .nameOnly {
                            if let imageData = folder.imageData ?? folder.items.first(where: { $0.imageData != nil })?.imageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        Text(folder.name)
                    }
                }
                .contextMenu {
                    Button(role: .destructive) {
                        folderToDelete = folder
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete Folder", systemImage: "trash")
                    }
                }
            }
            .onDelete { indexSet in
                if let index = indexSet.first {
                    folderToDelete = folders[index]
                    showingDeleteAlert = true
                }
            }
        }
    }
}
