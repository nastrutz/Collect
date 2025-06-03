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

    init(timestamp: Date, name: String, imageData: Data? = nil) {
        self.timestamp = timestamp
        self.name = name
        self.imageData = imageData
    }
}
