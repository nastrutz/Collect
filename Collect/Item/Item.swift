//
//  Item.swift
//  Collect
//
//  Created by Nic-Alexander Strutz on 6/2/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var name: String
    var imageData: Data?
    @Relationship var folder: Folder?
    var tags: [String] = []

    init(timestamp: Date, name: String, imageData: Data? = nil, folder: Folder? = nil, tags: [String] = []) {
        self.timestamp = timestamp
        self.name = name
        self.imageData = imageData
        self.folder = folder
        self.tags = tags
    }
}
