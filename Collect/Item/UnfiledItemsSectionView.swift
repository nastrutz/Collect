//
//  UnfiledItemsSectionView.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/6/25.
//

import SwiftUI
import SwiftData

struct UnfiledItemsSectionView: View {
    let items: [Item]
    let folders: [Folder]
    let displayMode: DisplayMode
    let modelContext: ModelContext
    @AppStorage("themeRed") private var themeRed: Double = 0.0
    @AppStorage("themeGreen") private var themeGreen: Double = 0.478
    @AppStorage("themeBlue") private var themeBlue: Double = 1.0
    
    var body: some View {
        Section(header: Text("Unfiled items"), content: {
            switch displayMode {
            case .nameOnly:
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        Text(item.name)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            modelContext.delete(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Menu {
                            ForEach(folders) { folder in
                                Button(folder.name) {
                                    item.folder = folder
                                }
                            }
                        } label: {
                            Label("Change Folder", systemImage: "folder")
                        }
                    }
                }
                .onDelete(perform: deleteItems)
                
            case .nameAndImage:
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        HStack {
                            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            Text(item.name)
                                .font(.body)
                        }
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            modelContext.delete(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Menu {
                            ForEach(folders) { folder in
                                Button(folder.name) {
                                    item.folder = folder
                                }
                            }
                        } label: {
                            Label("Change Folder", systemImage: "folder")
                        }
                    }
                }
                .onDelete(perform: deleteItems)
                
            case .imageOnly:
                ItemGridView(items: items)
            }
        })
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            modelContext.delete(item)
        }
    }
}
