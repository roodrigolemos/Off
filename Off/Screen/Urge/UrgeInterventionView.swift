//
//  UrgeInterventionView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct UrgeInterventionView: View {

    @Environment(\.dismiss) var dismiss
    @Environment(UrgeManager.self) var urgeManager

    @State private var currentStep: InterventionStep = .futurePrediction
    @State private var selectedReason: UrgeReason = .distraction

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.offBackgroundPrimary, .offAccentSoft.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [.offAccent.opacity(0.06), .clear],
                center: UnitPoint(x: 0.5, y: 0.15),
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                stepContent
            }
        }
        .onAppear { urgeManager.startSession() }
        .onDisappear { urgeManager.abandonSession() }
    }
}

// MARK: - Sections

private extension UrgeInterventionView {

    var headerSection: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(.offAccent)
                Text("Conscious Pause")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.offTextPrimary)
            }

            Spacer()

            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.offTextSecondary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(.offBackgroundSecondary.opacity(0.6))
                            .overlay(
                                Circle()
                                    .stroke(.offStroke.opacity(0.5), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    var stepContent: some View {
        ZStack {
            switch currentStep {
            case .futurePrediction:
                FuturePredictionView { feeling in
                    urgeManager.setPredictedFeeling(feeling)
                    advanceToStep(.seeking)
                }
                .transition(stepTransition)

            case .seeking:
                SeekingView { reason in
                    urgeManager.setSeekingWhat(reason)
                    selectedReason = reason
                    advanceToStep(.memoryCheck)
                }
                .transition(stepTransition)

            case .memoryCheck:
                MemoryCheckView(reason: selectedReason) { memory in
                    urgeManager.setMemoryOfSuccess(memory)
                    advanceToStep(.realityCheck)
                }
                .transition(stepTransition)

            case .realityCheck:
                RealityCheckView(reason: selectedReason) {
                    urgeManager.advanceScreen(4)
                    advanceToStep(.commitment)
                }
                .transition(stepTransition)

            case .commitment:
                CommitmentView {
                    urgeManager.advanceScreen(5)
                    advanceToStep(.breathingChoice)
                }
                .transition(stepTransition)

            case .breathingChoice:
                BreathingChoiceView { choice in
                    urgeManager.completeSession(finalChoice: choice)
                    dismiss()
                }
                .transition(stepTransition)
            }
        }
    }
}

// MARK: - Helpers

private extension UrgeInterventionView {

    var stepTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .move(edge: .trailing)).combined(with: .offset(x: 40)),
            removal: .opacity.combined(with: .move(edge: .leading)).combined(with: .offset(x: -20))
        )
    }

    func advanceToStep(_ step: InterventionStep) {
        withAnimation(.spring(duration: 0.6, bounce: 0.05)) {
            currentStep = step
        }
    }
}

#Preview {
    UrgeInterventionView()
        .withPreviewManagers()
}
