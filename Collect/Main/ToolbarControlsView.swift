//
//  ToolbarControlsView.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/6/25.
//

import SwiftUI

struct ToolbarControlsView: View {
    @Binding var displayMode: DisplayMode
    let currentThemeColor: Color
    let badgeManager: BadgeManager
    let hideBadgesManually: Bool

    var body: some View {
        HStack {
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
            .tint(currentThemeColor)

            if !badgeManager.hideBadges && !hideBadgesManually {
                if badgeManager.badge20Unlocked {
                    badgeIcon(.purple)
                } else if badgeManager.badge10Unlocked {
                    badgeIcon(.yellow)
                } else if badgeManager.badge5Unlocked {
                    badgeIcon(.gray)
                }
            }
        }
    }

    private func badgeIcon(_ color: Color) -> some View {
        ZStack {
            BadgeLabel(title: "5 Items", color: color, unlocked: true)
            Image(systemName: "seal")
                .foregroundColor(.black)
                .font(.system(size: 22, weight: .light))
        }
    }
}
