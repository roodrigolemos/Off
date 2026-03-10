//
//  BreathingChoiceView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct BreathingChoiceView: View {

    var onComplete: (FinalChoice) -> Void

    @State private var isExpanded = false
    @State private var countdown: Int = 30
    @State private var showButtons = false

    var body: some View {
        GeometryReader { geo in
            let minSize = geo.size.width * 0.30
            let maxSize = geo.size.width * 0.60
            let circleSize = isExpanded ? maxSize : minSize

            VStack(spacing: 16) {
                Spacer().frame(maxHeight: 50)
                titleSection
                breathingCircle(circleSize: circleSize, maxSize: maxSize)
                countdownSection
                Spacer()
                choiceButtons
            }
            .frame(maxWidth: .infinity)
        }
        .onAppear { startBreathingCycle() }
    }
}

// MARK: - Sections

private extension BreathingChoiceView {

    var titleSection: some View {
        Text("Breathe with the circle")
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.offTextPrimary)
    }

    func breathingCircle(circleSize: CGFloat, maxSize: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(.offAccent.opacity(0.02))
                .frame(width: circleSize * 1.5, height: circleSize * 1.5)

            Circle()
                .fill(.offAccent.opacity(0.03))
                .frame(width: circleSize * 1.3, height: circleSize * 1.3)

            Circle()
                .fill(.offAccent.opacity(0.06))
                .frame(width: circleSize * 1.15, height: circleSize * 1.15)

            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.offAccent, .offAccent.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 2.5
                )
                .frame(width: circleSize, height: circleSize)

            Text(isExpanded ? "Breathe out..." : "Breathe in...")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.offAccent)
        }
        .frame(width: maxSize * 1.5, height: maxSize * 1.5)
        .animation(.easeInOut(duration: 4.5), value: isExpanded)
    }

    @ViewBuilder
    var countdownSection: some View {
        if countdown > 0 {
            Text("\(countdown)")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.offTextMuted)
        }
    }

    @ViewBuilder
    var choiceButtons: some View {
        if showButtons {
            VStack(spacing: 14) {
                Button { onComplete(.resisted) } label: {
                    Text("\u{2705} I won't use it")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [.offAccent, .offAccent.opacity(0.85)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .offAccent.opacity(0.3), radius: 8, y: 4)
                        )
                }

                Button { onComplete(.usedAnyway) } label: {
                    Text("\u{1F4F1} I'll use it knowing this")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.offTextMuted)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .transition(.opacity)
        }
    }
}

// MARK: - Helpers

private extension BreathingChoiceView {

    func startBreathingCycle() {
        Timer.scheduledTimer(withTimeInterval: 4.5, repeats: true) { _ in
            isExpanded.toggle()
        }

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
                withAnimation(.easeIn(duration: 0.5)) {
                    showButtons = true
                }
            }
        }

        isExpanded = true
    }
}

#Preview {
    BreathingChoiceView { _ in }
        .withPreviewManagers()
}
