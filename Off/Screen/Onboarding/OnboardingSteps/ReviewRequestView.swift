//
//  ReviewRequestView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI
import StoreKit

struct ReviewRequestView: View {

    @Environment(\.requestReview) private var requestReview

    @State private var showContinue = false

    var onNext: () -> Void

    var body: some View {
        ZStack {
            Color.offBackgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                Spacer().frame(height: 50)
                starsSection
                Spacer().frame(height: 50)
                testimonialsSection
                Spacer()

                if showContinue {
                    continueButton
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 24)
        }
        .task {
            try? await Task.sleep(for: .seconds(4))
            requestReview()
            try? await Task.sleep(for: .seconds(1))
            withAnimation(.easeIn(duration: 0.4)) {
                showContinue = true
            }
        }
    }
}

// MARK: - Sections

private extension ReviewRequestView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Most people feel something's wrong but never stop to understand it")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .tracking(-0.3)

            Text("You did!")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
    }

    var starsSection: some View {
        HStack(spacing: 12) {
            ForEach(0..<5, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.offAccent, Color.offAccent.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        }
        .frame(maxWidth: .infinity)
    }

    var testimonialsSection: some View {
        VStack(spacing: 12) {
            testimonialCard(
                quote: "I started reading before bed again. My head feels so much clearer.",
                author: "Lucas"
            )
            testimonialCard(
                quote: "I didn't realize how automatic the scrolling had become until Off helped me see the pattern.",
                author: "Marina"
            )
        }
    }

    var continueButton: some View {
        Button {
            onNext()
        } label: {
            Text("Continue")
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
}

// MARK: - Helper Views
private extension ReviewRequestView {

    func testimonialCard(quote: String, author: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "quote.opening")
                .font(.system(size: 14))
                .foregroundStyle(Color.offAccent)

            Text(quote)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.offTextPrimary)
                .lineSpacing(3)
                .italic()

            Text("— \(author)")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.offTextMuted)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.offBackgroundSecondary)
                .overlay(
                    LinearGradient(
                        colors: [Color.offAccent.opacity(0.04), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.offStroke, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.03), radius: 8, y: 4)
        )
    }
}

#Preview {
    ReviewRequestView(onNext: { })
}
