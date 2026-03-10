//
//  SeekingView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct SeekingView: View {

    var onSelect: (UrgeReason) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)
                iconSection
                questionSection
                optionsSection
                Spacer(minLength: 40)
            }
        }
    }
}

// MARK: - Sections

private extension SeekingView {

    var iconSection: some View {
        Image(systemName: "magnifyingglass")
            .font(.system(size: 48, weight: .light))
            .foregroundStyle(.offAccent.opacity(0.15))
    }

    var questionSection: some View {
        Text("What are you seeking right now?")
            .font(.system(size: 26, weight: .bold))
            .foregroundStyle(.offTextPrimary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
    }

    var optionsSection: some View {
        VStack(spacing: 12) {
            optionButton(emoji: "\u{1F3AF}", label: "Distraction") { onSelect(.distraction) }
            optionButton(emoji: "\u{1F630}", label: "Relief from anxiety") { onSelect(.anxiety) }
            optionButton(emoji: "\u{1F91D}", label: "Connection") { onSelect(.connection) }
            optionButton(emoji: "\u{1F634}", label: "Escape tiredness") { onSelect(.tiredness) }
            optionButton(emoji: "\u{1F937}", label: "Automatic") { onSelect(.automatic) }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - View Helpers

private extension SeekingView {

    func optionButton(emoji: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 24))
                Text(label)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.offTextPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.offBackgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.7), .offAccent.opacity(0.03)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.offStroke.opacity(0.7), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
            )
        }
    }
}

#Preview {
    SeekingView { _ in }
        .withPreviewManagers()
}
