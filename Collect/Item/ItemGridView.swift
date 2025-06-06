//
//  ItemGridView.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/3/25.
//

import SwiftUI

struct ItemGridView: View {
    @AppStorage("themeRed") private var themeRed: Double = 0.0
    @AppStorage("themeGreen") private var themeGreen: Double = 0.0
    @AppStorage("themeBlue") private var themeBlue: Double = 0.0
    let items: [Item]

    var body: some View {
        if !items.isEmpty {
            ScrollView {
                let screenWidth = UIScreen.main.bounds.width
                let spacing: CGFloat = 16
                let minCellWidth: CGFloat = 150
                let columnsCount = max(Int((screenWidth - spacing) / (minCellWidth + spacing)), 1)

                let columns = Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnsCount)

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
                                            .font(item.name.count <= 8 ? .title3 : .caption)
                                            .multilineTextAlignment(.center)
                                            .padding(4)
                                            .foregroundColor(Color(red: themeRed, green: themeGreen, blue: themeBlue))
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.7)
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
