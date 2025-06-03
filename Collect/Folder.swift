//
//  Folder.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/3/25.
//


import Foundation
import SwiftData

@Model
final class Folder: Hashable {
    var name: String
    @Relationship(deleteRule: .cascade) var items: [Item]

    init(name: String, items: [Item] = []) {
        self.name = name
        self.items = items
    }

    static func == (lhs: Folder, rhs: Folder) -> Bool {
        lhs.name == rhs.name // or use a UUID property if available
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name) // or combine a UUID
    }
}
