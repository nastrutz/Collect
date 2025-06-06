//
//  BadgeLabel.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/5/25.
//


import SwiftUI

struct BadgeLabel: View {
    let title: String
    let color: Color
    let unlocked: Bool

    var body: some View {
        Label {
            Text(title)
                .foregroundColor(unlocked ? color : color.opacity(0.3))
        } icon: {
            Image(systemName: "seal.fill")
                .foregroundStyle(
                    unlocked ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white, color, Color.white]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.3),
                                color.opacity(0.3),
                                Color.white.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                )
        }
    }
}
