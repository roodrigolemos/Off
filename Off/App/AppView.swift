//
//  AppView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct AppView: View {

    @Environment(AppState.self) var appState

    var body: some View {
        AppViewBuilder(
            showTabBar: appState.showTabBar,
            tabbarView: {
                TabBarView()
            },
            onboardingView: {
                OnboardingView()
            }
        )
    }
}

#Preview("AppView - Tabbar") {
    AppView()
        .environment(AppState(showTabBar: true))
        .withPreviewManagers()
}

#Preview("AppView - Onboarding") {
    AppView()
        .environment(AppState(showTabBar: false))
        .withPreviewManagers()
}
