//
//  FolderDetailView.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/3/25.
//


import SwiftUI

struct FolderDetailView: View {
    let folder: Folder
    let folders: [Folder]

    @State private var displayMode: DisplayMode = .nameAndImage

    enum DisplayMode: String, CaseIterable, Identifiable {
        case nameOnly = "Name"
        case nameAndImage = "Name + Image"
        case imageOnly = "Image"
        
        var id: String { rawValue }
    }

    var body: some View {
        Group {
            switch displayMode {
            case .nameOnly:
                List {
                    ForEach(folder.items) { item in
                        NavigationLink(destination: ItemDetailView(folders: folders, item: item)) {
                            Text(item.name)
                                .font(.body)
                        }
                    }
                }

            case .nameAndImage:
                List {
                    ForEach(folder.items) { item in
                        NavigationLink(destination: ItemDetailView(folders: folders, item: item)) {
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
                    }
                }

            case .imageOnly:
                ItemGridView(items: folder.items)
            }
        }
        .navigationTitle(folder.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Picker("View", selection: $displayMode) {
                    ForEach(DisplayMode.allCases) { mode in
                        Image(systemName: {
                            switch mode {
                            case .nameOnly: return "line.3.horizontal"
                            case .nameAndImage: return "list.bullet"
                            case .imageOnly: return "square.grid.2x2"
                            }
                        }()).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
            }
        }
    }
}
