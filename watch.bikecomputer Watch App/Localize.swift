//
//  Localize.swift
//  zonevirbrate
//
//  Created by Bill, Yiu Por Chan on 27/12/2024.
//

import Foundation

/// TODO: mv to utilities
extension String {
    /// Returns the NSLocalizedString version of self
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
