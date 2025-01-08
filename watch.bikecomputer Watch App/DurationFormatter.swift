//
//  DurationFormatter.swift
//  bikecomputer
//
//  Created by Bill, Yiu Por Chan on 08/01/2025.
//

import SwiftUI

extension DateComponentsFormatter {
  static func durationFormatter(unitsStyle: UnitsStyle = .brief) -> DateComponentsFormatter {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = unitsStyle // Use `.full` or `.spellOut` for pluralized units
    formatter.zeroFormattingBehavior = .dropAll
    return formatter
  }
  
  static func formattedWorkoutDuration(
    seconds: TimeInterval,
    unitsStyle: UnitsStyle = .brief
  ) -> String {
    return DateComponentsFormatter.durationFormatter(unitsStyle: unitsStyle).string(from: seconds) ?? ""
  }
}
