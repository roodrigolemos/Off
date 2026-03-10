//
//  WelcomeView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI

struct WelcomeView: View {

    var onNext: () -> Void

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                heroSection
                Spacer()
                ctaSection
            }
        }
    }
}

// MARK: - Sections
private extension WelcomeView {

    var heroSection: some View {
        VStack(spacing: 16) {
            Image("offSymbol")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)

            Text("Take your life back")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)

            Text("Regain focus, energy, and control over your time")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
        }
        .padding(.horizontal, 24)
    }

    var ctaSection: some View {
        VStack(spacing: 20) {
            Button { onNext() } label: {
                Text("Get started")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.85)], startPoint: .top, endPoint: .bottom))
                    )
                    .foregroundStyle(.white)
            }

            Text("By continuing, your agree to our Terms of Service and Privacy Policy")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.offTextMuted)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }
}

#Preview {
    WelcomeView(onNext: {})
}
