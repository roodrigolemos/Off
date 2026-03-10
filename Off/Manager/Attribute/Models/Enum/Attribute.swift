//
//  Attribute.swift
//  Off
//

import Foundation

enum Attribute: String, CaseIterable {
    
    case clarity, focus, energy, drive, control, patience

    var label: String {
        switch self {
        case .clarity: "Clarity"
        case .focus: "Focus"
        case .energy: "Energy"
        case .drive: "Drive"
        case .control: "Control"
        case .patience: "Patience"
        }
    }

    var lowLabel: String {
        switch self {
        case .clarity: "Foggy"
        case .focus: "Low"
        case .energy: "Low"
        case .drive: "Hard"
        case .control: "Autopilot"
        case .patience: "Urgent"
        }
    }

    var description: String {
        switch self {
        case .clarity: "How clear and organized your thoughts feel"
        case .focus: "Your ability to concentrate on one thing at a time"
        case .energy: "How energized and alive you feel throughout the day"
        case .drive: "How motivated you feel to pursue your goals"
        case .control: "How intentional you are about how you spend your time"
        case .patience: "How comfortable you are with waiting and slowing down"
        }
    }

    var highLabel: String {
        switch self {
        case .clarity: "Clear"
        case .focus: "High"
        case .energy: "High"
        case .drive: "Easy"
        case .control: "Intentional"
        case .patience: "Patient"
        }
    }

    var icon: String {
        switch self {
        case .clarity:  "brain.head.profile"
        case .focus:    "scope"
        case .energy:   "bolt.fill"
        case .drive:    "flag.checkered"
        case .control:  "hand.raised.slash.fill"
        case .patience: "hourglass"
        }
    }

    func projectedDescription(for score: Int) -> String {
        switch (self, score) {
        case (.clarity, 1...2): "Starting to notice clearer moments"
        case (.clarity, 3):     "Less mental fog over time"
        case (.clarity, 4):     "Thinking feels noticeably clearer"
        case (.clarity, 5):     "Sharp, clear thinking sustained"
        case (.focus, 1...2):   "Starting to hold focus longer"
        case (.focus, 3):       "Easier to hold focus"
        case (.focus, 4):       "Focus becomes more reliable"
        case (.focus, 5):       "Deep focus feels natural"
        case (.energy, 1...2):  "Fewer energy crashes expected"
        case (.energy, 3):      "More steady energy throughout the day"
        case (.energy, 4):      "Energy feels consistent and reliable"
        case (.energy, 5):      "Fully energized, sustained daily"
        case (.drive, 1...2):   "Less resistance getting started"
        case (.drive, 3):       "Getting started becomes easier"
        case (.drive, 4):       "Steady momentum building"
        case (.drive, 5):       "Drive feels strong and natural"
        case (.control, 1...2): "Catching yourself before scrolling"
        case (.control, 3):     "More intentional checking"
        case (.control, 4):     "Screen time feels deliberate"
        case (.control, 5):     "Fully in control of screen time"
        case (.patience, 1...2):"Less urgency building up"
        case (.patience, 3):    "Less urgency, more calm"
        case (.patience, 4):    "Comfortable with pausing"
        case (.patience, 5):    "Genuine patience sustained"
        default:                "Gradual improvement expected"
        }
    }

    func snapshotDescription(for score: Int) -> String {
        switch (self, score) {
        case (.clarity, 1):  "Mind feels clouded and foggy"
        case (.clarity, 2):  "Thoughts are foggy often"
        case (.clarity, 3):  "Clarity comes and goes daily"
        case (.clarity, 4):  "Thinking feels much clearer"
        case (.clarity, 5):  "Mind feels sharp and clear"
        case (.focus, 1):    "Very hard to concentrate"
        case (.focus, 2):    "Focus takes a lot of effort"
        case (.focus, 3):    "Focus comes and goes daily"
        case (.focus, 4):    "Can concentrate when needed"
        case (.focus, 5):    "Can lock in and stay focused"
        case (.energy, 1):   "Feeling drained most days"
        case (.energy, 2):   "Energy runs low most days"
        case (.energy, 3):   "Energy comes and goes daily"
        case (.energy, 4):   "Energy feels more steady now"
        case (.energy, 5):   "Fully energized every day"
        case (.drive, 1):    "Getting started feels heavy"
        case (.drive, 2):    "Starting things takes effort"
        case (.drive, 3):    "Motivation comes and goes"
        case (.drive, 4):    "Steady drive to move forward"
        case (.drive, 5):    "Fully motivated and driven"
        case (.control, 1):  "Screen time is on autopilot"
        case (.control, 2):  "Often scrolling mindlessly"
        case (.control, 3):  "Some intentional, some not"
        case (.control, 4):  "Mostly intentional screen use"
        case (.control, 5):  "Fully in control of screens"
        case (.patience, 1): "Slowing down feels very hard"
        case (.patience, 2): "Patience runs thin quickly"
        case (.patience, 3): "Patience varies by moment"
        case (.patience, 4): "Can wait calmly most times"
        case (.patience, 5): "Genuinely patient and calm"
        default:             "—"
        }
    }
}
