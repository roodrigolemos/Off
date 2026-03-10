//
//  UrgeReason.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

enum UrgeReason: Int, Codable {
    case distraction = 0
    case anxiety = 1
    case connection = 2
    case tiredness = 3
    case automatic = 4

    var memoryQuestion: String {
        switch self {
        case .distraction:
            "When was the last time you scrolled social media for 30 minutes and thought: 'Now I'm less bored'?"
        case .anxiety:
            "When was the last time you closed social media and thought: 'My anxiety improved'?"
        case .connection:
            "When was the last time you spent time on social media and thought: 'Now I feel more connected'?"
        case .tiredness:
            "When was the last time you used social media tired and thought: 'Now I have more energy'?"
        case .automatic:
            "When was the last time you used social media without thinking and then thought: 'Good thing I did that'?"
        }
    }

    var memorySubtitle: String {
        switch self {
        case .distraction:
            "Be honest with yourself."
        case .anxiety:
            "Not what you hoped would happen. What actually happened."
        case .connection:
            "Not the likes. The actual feeling after."
        case .tiredness:
            "How did you actually feel after?"
        case .automatic:
            "Was it even your choice?"
        }
    }

    var realityTitle: String {
        switch self {
        case .distraction:
            "You're bored."
        case .anxiety:
            "You're anxious."
        case .connection:
            "You want to connect."
        case .tiredness:
            "You're tired."
        case .automatic:
            "You don't even know why, just following the impulse."
        }
    }

    var realityBody: String {
        switch self {
        case .distraction:
            "Will social media fix it? No. You'll scroll for 30 minutes and still be bored, just also irritated with yourself."
        case .anxiety:
            "Will social media help? No. It promises relief but almost always makes anxiety worse. You know this."
        case .connection:
            "Will social media give you that? Not really. You'll see people, but feel more alone after."
        case .tiredness:
            "Will social media energize you? No. The screen light will make you more tired and worsen your sleep later."
        case .automatic:
            "Social media depends on this unconsciousness. Every time you open it without thinking, the habit gets stronger — not you."
        }
    }

    var realityHelpTitle: String {
        switch self {
        case .distraction:
            "What actually helps:"
        case .anxiety:
            "What actually helps:"
        case .connection:
            "Real connection:"
        case .tiredness:
            "Real rest:"
        case .automatic:
            "Stop for a second:"
        }
    }

    var realityHelpItems: [String] {
        switch self {
        case .distraction:
            ["Do something with your hands", "Go for a short walk", "Read a few pages of a book"]
        case .anxiety:
            ["Breathe for 2 minutes", "Write what you're feeling", "Talk to someone real"]
        case .connection:
            ["Message someone (not post)", "Call a friend", "Leave the house"]
        case .tiredness:
            ["Close your eyes for 10 minutes", "Drink water", "Actually lie down. Stop pretending you're not tired."]
        case .automatic:
            ["How do you feel now?", "What were you doing?", "Why did you stop? This awareness already breaks the automatism."]
        }
    }
}
