//
//  BadgeManager.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/5/25.
//


import Foundation
import SwiftUI

class BadgeManager: ObservableObject {
    init() {
        NotificationCenter.default.addObserver(forName: Notification.Name("ResetBadgesNotification"), object: nil, queue: .main) { _ in
            self.totalItemsCollected = 0
        }
    }
    static let shared = BadgeManager()
    @AppStorage("badge5Unlocked") var badge5Unlocked: Bool = false
    @AppStorage("badge10Unlocked") var badge10Unlocked: Bool = false
    @AppStorage("badge20Unlocked") var badge20Unlocked: Bool = false
    @AppStorage("totalItemsCollected") var totalItemsCollected: Int = 0
    @AppStorage("hideBadges") var hideBadges: Bool = false

    func incrementBadgeItems() {
        totalItemsCollected += 1

        if totalItemsCollected >= 5 {
            badge5Unlocked = true
        }
        if totalItemsCollected >= 10 {
            badge10Unlocked = true
        }
        if totalItemsCollected >= 20 {
            badge20Unlocked = true
        }
        if totalItemsCollected >= 21 {
            hideBadges = true
        }
    }

    func badgeStatus() -> [String: Bool] {
        return [
            "5 Items Organized": badge5Unlocked,
            "10 Items Organized": badge10Unlocked,
            "20 Items Organized": badge20Unlocked
        ]
    }
}
