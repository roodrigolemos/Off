//
//  ScreenTimePermissionView.swift
//  Off
//
//  Created by Rodrigo Lemos on 10/03/26.
//

import SwiftUI

struct ScreenTimePermissionView: View {

    @Environment(ScreenTimeManager.self) var screenTimeManager

    var onNext: () -> Void

    @State private var isRequestingAuthorization = false
    @State private var showAuthorizationRequiredAlert = false
//    @State private var hasAdvanced = false

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
        .alert("Screen Time access is required", isPresented: $showAuthorizationRequiredAlert) {
            Button("Try Again") {
                Task {
                    await requestAuthorization()
                }
            }
        } message: {
            Text("We need Screen Time access to set up your app limits and continue onboarding.")
        }
    }
}

// MARK: - Sections
private extension ScreenTimePermissionView {

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

                Image(systemName: "hourglass.badge.shield.half.filled")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Color.offAccent)
            }

            VStack(spacing: 10) {
                Text("Allow Screen Time access")
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundStyle(Color.offTextPrimary)
                    .multilineTextAlignment(.center)
                    .tracking(-0.3)

                Text("Off uses Screen Time permission to help you choose apps, apply limits, and keep your plan working.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.offTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            permissionCard
        }
    }

    var permissionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Required to continue setup", systemImage: "checkmark.seal.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.offTextPrimary)

            Text("When you tap the button below, iOS will ask for access. If you allow it, you'll move to the next step immediately.")
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
            Task {
                await requestAuthorization()
            }
        } label: {
            HStack(spacing: 10) {
                if isRequestingAuthorization {
                    ProgressView()
                        .tint(.white)
                }

                Text(isRequestingAuthorization ? "Requesting access..." : "Allow Screen Time access")
                    .font(.system(size: 16, weight: .semibold))
            }
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
        .disabled(isRequestingAuthorization)
        .opacity(isRequestingAuthorization ? 0.8 : 1)
        .padding(.bottom, 8)
    }

    func requestAuthorization() async {
        guard !isRequestingAuthorization else { return }

        isRequestingAuthorization = true
        await screenTimeManager.requestAuthorization()
        isRequestingAuthorization = false

        if screenTimeManager.isAuthorized {
            onNext()
        } else {
            showAuthorizationRequiredAlert = true
        }
    }
}

#Preview {
    ScreenTimePermissionView(onNext: {})
        .withPreviewManagers()
}
