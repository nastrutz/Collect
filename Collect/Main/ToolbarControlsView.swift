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
    @ObservedObject var badgeManager: BadgeManager
    let hideBadgesManually: Bool
    @State private var showingBadgeInfo = false

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

            if !hideBadgesManually {
                if badgeManager.badge20Unlocked {
                    badgeIcon(.purple)
                } else if badgeManager.badge10Unlocked {
                    badgeIcon(.yellow)
                } else if badgeManager.badge5Unlocked {
                    badgeIcon(.gray)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ResetBadgesNotification"))) { _ in
            showingBadgeInfo = false
        }
    }

    private func badgeIcon(_ color: Color) -> some View {
        Button {
            showingBadgeInfo = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showingBadgeInfo = false
            }
        } label: {
            ZStack {
                BadgeLabel(title: "", color: color, unlocked: true)
                    .font(.system(size: 15))
                Image(systemName: "seal")
                    .foregroundColor(.primary)
                    .font(.system(size: 17, weight: .light))
            }
        }
        .buttonStyle(.plain)
        .overlay(
            Group {
                if showingBadgeInfo {
                    Text("Total: \(badgeManager.totalItemsCollected)")
                        .font(.caption)
                        .padding(8)
                        .background(Color.primary.opacity(0.75))
                        .foregroundColor(Color(UIColor.systemBackground))
                        .cornerRadius(6)
                        .fixedSize()
                        .offset(y: 40)
                        .transition(.opacity)
                }
            },
            alignment: .top
        )
        .animation(.easeInOut(duration: 0.2), value: showingBadgeInfo)
    }
}
