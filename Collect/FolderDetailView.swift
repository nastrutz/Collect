//
//  FolderDetailView.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/3/25.
//


import SwiftUI

struct FolderDetailView: View {
    let folder: Folder

    var body: some View {
        List {
            ForEach(folder.items) { item in
                NavigationLink(destination: ItemDetailView(item: item)) {
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
        .navigationTitle(folder.name)
    }
}
