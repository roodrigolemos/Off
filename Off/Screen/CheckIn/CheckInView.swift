//
//  CheckInView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//

import SwiftUI

struct CheckInView: View {

    @Environment(\.dismiss) var dismiss
    @Environment(CheckInManager.self) var checkInManager
    @Environment(PlanManager.self) var planManager

    @State private var clarity: AttributeRating?
    @State private var focus: AttributeRating?
    @State private var energy: AttributeRating?
    @State private var drive: AttributeRating?
    @State private var patience: AttributeRating?
    @State private var control: ControlRating?
    @State private var urgeLevel: UrgeLevel?
    @State private var planAdherence: PlanAdherence?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                titleSection
                headerSection
                attributesSection
                urgeSection
                planSection
                submitSection
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.offBackgroundPrimary)
        .alert(
            "Error",
            isPresented: .init(
                get: { checkInManager.error != nil },
                set: { if !$0 { checkInManager.error = nil } }
            ),
            actions: { Button("OK") { checkInManager.error = nil } },
            message: { Text(checkInManager.error?.localizedDescription ?? "") }
        )
    }
}

#Preview {
    CheckInView()
        .withPreviewManagers()
}

// MARK: - Sections

private extension CheckInView {

    var titleSection: some View {
        HStack {
            Text("Check-in")
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)

            Spacer()

            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.offTextSecondary)
                    .frame(width: 32, height: 32)
                    .background(Color.offBackgroundSecondary)
                    .clipShape(Circle())
            }
        }
        .padding(.top, 16)
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reflect on your day")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.offTextPrimary)

            Text(checkInReferenceSubtitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.offTextSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
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

    var attributesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How your mind feels")
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)
                .padding(.top, 8)

            VStack(spacing: 12) {
                attributeCard(
                    icon: "brain.head.profile",
                    title: "Clarity",
                    subtitle: "Your mind feels",
                    selection: $clarity,
                    labels: [.worse: "Worse", .same: "Same", .better: "Better"]
                )
                attributeCard(
                    icon: "scope",
                    title: "Focus",
                    subtitle: "Sustaining attention feels",
                    selection: $focus,
                    labels: [.worse: "Worse", .same: "Same", .better: "Better"]
                )
                attributeCard(
                    icon: "bolt.fill",
                    title: "Energy",
                    subtitle: "Your mental energy feels",
                    selection: $energy,
                    labels: [.worse: "Worse", .same: "Same", .better: "Better"]
                )
                attributeCard(
                    icon: "flag.checkered",
                    title: "Drive",
                    subtitle: "Starting things feels",
                    selection: $drive,
                    labels: [.worse: "Worse", .same: "Same", .better: "Better"]
                )
                attributeCard(
                    icon: "hand.raised.slash.fill",
                    title: "Control",
                    subtitle: "Your phone use feels",
                    selection: $control,
                    labels: [.automatic: "Automatic", .same: "Same", .conscious: "Conscious"]
                )
                attributeCard(
                    icon: "hourglass",
                    title: "Patience",
                    subtitle: "Your tolerance for boredom feels",
                    selection: $patience,
                    labels: [.worse: "Worse", .same: "Same", .better: "Better"]
                )
            }
        }
    }

    var urgeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Urge")
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)
                .padding(.top, 8)

            attributeCard(
                icon: "flame.fill",
                title: "Urge",
                subtitle: "How strong was your urge to use social media today?",
                selection: $urgeLevel,
                labels: [.none: "None", .noticeable: "Noticeable", .persistent: "Persistent", .tookOver: "Took over"]
            )
        }
    }

    var planSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Plan")
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(Color.offTextPrimary)
                .tracking(-0.3)
                .padding(.top, 8)

            attributeCard(
                icon: "calendar.badge.checkmark",
                title: "Did you follow your plan today?",
                subtitle: isPlanDay
                    ? "This is only used to interpret the weekly pattern."
                    : "Today is not a plan day. You can skip this.",
                selection: $planAdherence,
                labels: [.yes: "Yes", .partially: "Partially", .no: "No"]
            )
        }
    }

    var submitSection: some View {
        Button {
            guard let clarity, let focus, let energy, let drive,
                  let patience, let control, let urgeLevel else { return }

            let snapshot = CheckInSnapshot(
                clarity: clarity,
                focus: focus,
                energy: energy,
                drive: drive,
                patience: patience,
                control: control,
                urgeLevel: urgeLevel,
                planAdherence: planAdherence,
                wasPlanDay: isPlanDay
            )
            checkInManager.save(snapshot)

            if checkInManager.error == nil {
                dismiss()
            }
        } label: {
            HStack {
                Text("Save")
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .semibold))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.85)], startPoint: .top, endPoint: .bottom))
            )
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .disabled(!allAnswered)
        .opacity(allAnswered ? 1 : 0.5)
        .padding(.top, 12)
    }
}

// MARK: - View Helpers

private extension CheckInView {

    func attributeCard<T: Hashable>(
        icon: String,
        title: String,
        subtitle: String,
        selection: Binding<T?>,
        labels: KeyValuePairs<T, String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [Color.offAccent.opacity(0.15), Color.offAccent.opacity(0.05)], center: .center, startRadius: 0, endRadius: 16))
                        .frame(width: 32, height: 32)

                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(LinearGradient(colors: [Color.offAccent, Color.offAccent.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.offTextPrimary)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.offTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 10) {
                ForEach(Array(labels), id: \.key) { key, label in
                    let isSelected = selection.wrappedValue == key
                    Button { selection.wrappedValue = key } label: {
                        Text(label)
                            .font(.system(size: 13, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .foregroundStyle(isSelected ? .white : Color.offTextPrimary)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(isSelected ? Color.offAccent : Color.offBackgroundPrimary)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(isSelected ? Color.offAccent : Color.offStroke, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
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

private extension CheckInView {

    var isPlanDay: Bool {
        planManager.isPlanDay
    }

    var checkInReferenceSubtitle: String {
        if planManager.hasCompletedFirstWeeklyCycle {
            return "Answer based on how you feel today, compared to last week."
        }
        return "Answer based on how you feel today, since you started reducing social media."
    }

    var allAnswered: Bool {
        clarity != nil
        && focus != nil
        && energy != nil
        && drive != nil
        && patience != nil
        && control != nil
        && urgeLevel != nil
        && (!isPlanDay || planAdherence != nil)
    }
}
