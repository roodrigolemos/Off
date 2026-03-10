//
//  MirrorStateView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI

struct MirrorStateView: View {

    @Environment(OnboardingManager.self) var onboardingManager
    
    @State private var selectedCards: Set<Int> = []

    var onNext: () -> Void
    
    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                cardsSection
                ctaSection
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Sections
private extension MirrorStateView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Does this feel familiar?")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)

            Text("Pick what matches how you feel")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    var cardsSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                cardButton(index: 0, image: "brainTired", title: "Mental fatigue, even on easy days", subtitle: "You feel drained without a clear reason")
                cardButton(index: 1, image: "brainSimpleTask", title: "Simple tasks feel harder than they should", subtitle: "Starting takes more effort than before")
                cardButton(index: 2, image: "brainScrolling", title: "Picking up your phone without noticing", subtitle: "You unlock it without intention")
                cardButton(index: 3, image: "restlessMind", title: "Feeling restless when things slow down", subtitle: "Silence feels uncomfortable")
                cardButton(index: 4, image: "startIsHard", title: "Starting feels like the hardest part", subtitle: "Even important things get delayed")
                cardButton(index: 5, image: "endlessScroll", title: "Scrolling longer than you planned", subtitle: "One minute turns into many")
            }
            .animation(.smooth, value: selectedCards)
            .padding(.bottom, 12)
        }
    }

    var ctaSection: some View {
        Button {
            onboardingManager.setSelectedMirrorCards(selectedCards)
            onNext()
        } label: {
            Text("That's me")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.85)], startPoint: .top, endPoint: .bottom))
                )
                .foregroundStyle(.white)
        }
        .disabled(!hasSelection)
        .opacity(hasSelection ? 1 : 0.45)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

// MARK: - Helper Views
private extension MirrorStateView {

    func cardButton(index: Int, image: String, title: String, subtitle: String) -> some View {
        Button {
            if selectedCards.contains(index) {
                selectedCards.remove(index)
            } else {
                selectedCards.insert(index)
            }
        } label: {
            mirrorCard(image: image, title: title, subtitle: subtitle, isSelected: selectedCards.contains(index))
        }
        .buttonStyle(.plain)
    }
    
    
    func mirrorCard(image: String, title: String, subtitle: String, isSelected: Bool) -> some View {
        HStack(spacing: 16) {
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.offTextPrimary)

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
            }

            Spacer()

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isSelected ? Color.offAccent : Color.offDotInactive)
                .padding(.top, 2)
        }
        .padding(20)
        .frame(maxWidth: 520, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.offBackgroundSecondary)

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(LinearGradient(colors: [Color.offAccent.opacity(0.04), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Helpers
private extension MirrorStateView {

    var hasSelection: Bool { !selectedCards.isEmpty }
}

#Preview {
    MirrorStateView(onNext: {})
        .environment(OnboardingManager())
}
