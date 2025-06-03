//
//  ItemDetailView.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/3/25.
//


import SwiftUI

struct ItemDetailView: View {
    let item: Item

    var body: some View {
        ScrollView {
            VStack {
                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(item.name)
                    .font(.largeTitle)
                    .bold()
            }
        }
    }
}
