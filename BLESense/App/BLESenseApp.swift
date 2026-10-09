//
//  BLESenseApp.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Main application entry point with tab navigation and state management.
//

import SwiftUI

@main
struct BLESenseApp: App {
    @StateObject private var bleManager = BLECentralManager.shared
    @StateObject private var theme = ThemeManager.shared
    @State private var selectedTab: AppTab = .dashboard
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .bottom) {
                Group {
                    switch selectedTab {
                    case .dashboard:
                        MainDashboardView()
                    case .sensorHub:
                        NavigationStack { SensorHubView() }
                    case .dataLogger:
                        NavigationStack { DataLoggerListView() }
                    case .awsStation:
                        NavigationStack { AWSScannerView() }
                    case .robotControl:
                        RobotControlView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Floating Bottom Navigation Bar (Hidden in Robot Drive Mode)
                if selectedTab != .robotControl {
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
            .preferredColorScheme(theme.isDarkMode ? .dark : .light)
            .onAppear {
                bleManager.startScan()
            }
        }
    }
}
