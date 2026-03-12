//
//  ScreenTimeAppsView.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

import SwiftUI
import FamilyControls

struct ScreenTimeAppsView: View {

    @Environment(OnboardingManager.self) var onboardingManager
    @Environment(ScreenTimeManager.self) var screenTimeManager

    var onNext: () -> Void

    @State private var activitySelection = FamilyActivitySelection()
    @State private var showActivityPicker = false

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                contentSection
                Spacer()
                ctaSection
            }
            .padding(.horizontal, 24)
        }
        .familyActivityPicker(isPresented: $showActivityPicker, selection: $activitySelection)
        .onChange(of: showActivityPicker) { _, isPresented in
            guard !isPresented else { return }
            handlePickerDismissal()
        }
    }
}

#Preview {
    ScreenTimeAppsView(onNext: {})
        .withPreviewManagers()
}

// MARK: - Sections
private extension ScreenTimeAppsView {

    var contentSection: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.offAccent.opacity(0.18), Color.offAccent.opacity(0.05)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 72
                        )
                    )
                    .frame(width: 132, height: 132)

                Image(systemName: "apps.iphone.badge.plus")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(Color.offAccent)
            }

            VStack(spacing: 10) {
                Text("Choose the apps to limit")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundStyle(Color.offTextPrimary)
                    .multilineTextAlignment(.center)
                    .tracking(-0.3)

                Text("Pick the apps, categories, or websites you want Off to help you control. You need at least one selection to continue.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            selectionCard
        }
    }

    var selectionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Select at least one item", systemImage: "checkmark.circle.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.offTextPrimary)

            Text("After you dismiss the picker, Off will continue automatically if you chose any app, category, or website.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
        }
        .padding(20)
        .frame(maxWidth: 520, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.offBackgroundSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.offStroke, lineWidth: 1)
        )
    }

    var ctaSection: some View {
        Button {
            showActivityPicker = true
        } label: {
            Text("Choose apps")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.offAccent, Color.offAccent.opacity(0.85)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .foregroundStyle(.white)
        }
        .padding(.bottom, 8)
    }

    func handlePickerDismissal() {
        onboardingManager.setActivitySelection(activitySelection)
        
        guard !activitySelection.applicationTokens.isEmpty
        || !activitySelection.categoryTokens.isEmpty
        || !activitySelection.webDomainTokens.isEmpty else { return }
        
        onNext()
    }
}
