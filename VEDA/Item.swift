//
//  Item.swift
//  VEDA
//
//  Created by Johnny Lau on 2026-02-22.
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
