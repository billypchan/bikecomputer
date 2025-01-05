//
//  Item.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 05/01/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
