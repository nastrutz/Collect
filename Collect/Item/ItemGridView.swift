//
//  ItemGridView.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/3/25.
//


import SwiftUI

struct ItemGridView: View {
    let items: [Item]

    var body: some View {
        if !items.isEmpty {
            ScrollView {
                let columns = [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ]

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(items) { item in
                        NavigationLink(value: item) {
                            VStack {
                                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: (UIScreen.main.bounds.width - 96) / 2, height: (UIScreen.main.bounds.width - 96) / 2)
                                        .clipped()
                                        .cornerRadius(8)
                                } else {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: (UIScreen.main.bounds.width - 96) / 2, height: (UIScreen.main.bounds.width - 96) / 2)
                                        Text(item.name)
                                            .font(.caption)
                                            .multilineTextAlignment(.center)
                                            .padding(4)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top, 16)
            }
        }
    }
}
