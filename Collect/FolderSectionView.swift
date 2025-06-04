//
//  FolderSectionView.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/3/25.
//


import SwiftUI
import SwiftData
import LocalAuthentication

struct FolderSectionView: View {
    @AppStorage("enableFolderLocking") private var enableFolderLocking: Bool = true
    let folders: [Folder]
    let modelContext: ModelContext
    let displayMode: DisplayMode
    @Binding var folderToDelete: Folder?
    @Binding var showingDeleteAlert: Bool
    @Binding var path: NavigationPath

    var body: some View {
        Section(header: Text("Folders")) {
            ForEach(folders) { folder in
                Button {
                    if folder.isLocked && enableFolderLocking {
                        authenticateAndNavigate(folder: folder)
                    } else {
                        path.append(folder)
                    }
                } label: {
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

    func authenticateAndNavigate(folder: Folder) {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            path.append(folder)
            return
        }
        #endif

        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock folder") { success, _ in
                if success {
                    DispatchQueue.main.async {
                        path.append(folder)
                    }
                }
            }
        }
    }
}
