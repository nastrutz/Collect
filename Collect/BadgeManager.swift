//
//  BadgeManager.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/5/25.
//


import Foundation
import SwiftUI

class BadgeManager: ObservableObject {
    @AppStorage("badge5Unlocked") var badge5Unlocked: Bool = false
    @AppStorage("badge10Unlocked") var badge10Unlocked: Bool = false
    @AppStorage("badge20Unlocked") var badge20Unlocked: Bool = false

    func updateBadges(for items: [Item]) {
        let organizedCount = items.filter { $0.folder != nil }.count

        if organizedCount >= 5 {
            badge5Unlocked = true
        }
        if organizedCount >= 10 {
            badge10Unlocked = true
        }
        if organizedCount >= 20 {
            badge20Unlocked = true
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
