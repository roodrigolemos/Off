//
//  ReframeIntroView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI

struct ReframeIntroView: View {
    
    @State private var brainStage = 0
    @State private var hasAnimated = false

    var onNext: () -> Void
    
    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                Spacer()
                brainSection
                Spacer()
                ctaSection
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Sections
private extension ReframeIntroView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nothing is wrong with you")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)
                .lineLimit(2)
                .minimumScaleFactor(0.9)

            Text("Your brain adapts to the kind of stimulation it gets.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)

            Text("Fast, constant feedback pulls motivation toward what's easy, and makes effort feel heavier over time.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    var brainSection: some View {
        VStack(spacing: 12) {
            Image(brainImages[brainStage])
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)

            Button { animateBrainDecay() } label: {
                Text("Give more stimulation")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.offAccentSoft)
                    )
                    .foregroundStyle(Color.offTextPrimary)
            }
            .buttonStyle(.plain)
            .disabled(hasAnimated)
            .opacity(hasAnimated ? 0.5 : 1)
        }
    }

    var ctaSection: some View {
        Button { onNext() } label: {
            Text("Continue")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.85)], startPoint: .top, endPoint: .bottom))
                )
                .foregroundStyle(.white)
        }
        .disabled(!hasAnimated)
        .opacity(hasAnimated ? 1 : 0.5)
        .animation(.easeInOut(duration: 0.3), value: hasAnimated)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

// MARK: - Helpers
private extension ReframeIntroView {

    var brainImages: [String] {
        ["brainPerfectlyHealhty",
         "brainSlightRot",
         "brainModerateRot",
         "brainSevereRot",
         "brainFullRot"]
    }

    func animateBrainDecay() {
        hasAnimated = true
        for i in 1...4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    brainStage = i
                }
            }
        }
    }
}

#Preview {
    ReframeIntroView(onNext: {})
}
