//
//  TabBarView.swift
//  Off
//
//  Created by Rodrigo Lemos on 11/02/26.
//


import SwiftUI

struct TabBarView: View {

    @State private var selectedTab: Tab = .home

    private enum Tab: Hashable {
        case home
        case you
        case usage
        case settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(Tab.home)
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            YouView()
                .tag(Tab.you)
                .tabItem {
                    Label("You", systemImage: "sparkles")
                }

            UsageView()
                .tag(Tab.usage)
                .tabItem {
                    Label("Usage", systemImage: "clock.fill")
                }

            SettingsView()
                .tag(Tab.settings)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .tint(.offAccent)
    }
}

#Preview {
    TabBarView()
        .withPreviewManagers()
}
