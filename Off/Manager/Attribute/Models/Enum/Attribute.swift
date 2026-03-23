//
//  Attribute.swift
//  Off
//

import Foundation

enum Attribute: String, CaseIterable {
    
    case energy, focus, action, control

    var label: String {
        switch self {
        case .energy: "Energy"
        case .focus: "Focus"
        case .action: "Action"
        case .control: "Control"
        }
    }

    var lowLabel: String {
        switch self {
        case .energy: "Low"
        case .focus: "Low"
        case .action: "Stuck"
        case .control: "Autopilot"
        }
    }

    var description: String {
        switch self {
        case .energy: "How energized and alive you feel throughout the day"
        case .focus: "Your ability to concentrate on one thing at a time"
        case .action: "How easily you start and follow through on what matters"
        case .control: "How intentional you are about how you spend your time"
        }
    }

    var highLabel: String {
        switch self {
        case .energy: "High"
        case .focus: "High"
        case .action: "Moving"
        case .control: "Intentional"
        }
    }

    var icon: String {
        switch self {
        case .energy:   "bolt.fill"
        case .focus:    "scope"
        case .action:   "flag.checkered"
        case .control:  "hand.raised.slash.fill"
        }
    }

    func projectedDescription(for score: Int) -> String {
        switch (self, score) {
        case (.focus, 1...2):   "Starting to hold focus longer"
        case (.focus, 3):       "Easier to hold focus"
        case (.focus, 4):       "Focus becomes more reliable"
        case (.focus, 5):       "Deep focus feels natural"
        case (.control, 1...2): "Catching yourself before scrolling"
        case (.control, 3):     "More intentional checking"
        case (.control, 4):     "Screen time feels deliberate"
        case (.control, 5):     "Fully in control of screen time"
        case (.action, 1...2):  "Taking the first step feels easier"
        case (.action, 3):      "Following through gets easier"
        case (.action, 4):      "Action feels more natural"
        case (.action, 5):      "Consistent follow-through"
        case (.energy, 1...2):  "Fewer energy crashes expected"
        case (.energy, 3):      "More steady energy throughout the day"
        case (.energy, 4):      "Energy feels consistent and reliable"
        case (.energy, 5):      "Fully energized, sustained daily"
        default:                "Gradual improvement expected"
        }
    }

    func snapshotDescription(for score: Int) -> String {
        switch (self, score) {
        case (.focus, 1):    "Very hard to concentrate"
        case (.focus, 2):    "Focus takes a lot of effort"
        case (.focus, 3):    "Focus comes and goes daily"
        case (.focus, 4):    "Can concentrate when needed"
        case (.focus, 5):    "Can lock in and stay focused"
        case (.control, 1):  "Screen time is on autopilot"
        case (.control, 2):  "Often scrolling mindlessly"
        case (.control, 3):  "Some intentional, some not"
        case (.control, 4):  "Mostly intentional screen use"
        case (.control, 5):  "Fully in control of screens"
        case (.action, 1):   "Starting feels blocked"
        case (.action, 2):   "Taking action takes effort"
        case (.action, 3):   "Follow-through comes and goes"
        case (.action, 4):   "Taking action feels easier"
        case (.action, 5):   "Consistent action and follow-through"
        case (.energy, 1):   "Feeling drained most days"
        case (.energy, 2):   "Energy runs low most days"
        case (.energy, 3):   "Energy comes and goes daily"
        case (.energy, 4):   "Energy feels more steady now"
        case (.energy, 5):   "Fully energized every day"
        default:             "—"
        }
    }
}
