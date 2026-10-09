//
//  SettingsView.swift
//  BLESense
//
//  Created for BLESense iOS.
//  App configuration, Bluetooth scan mode toggles, and App Store metadata.
//

import SwiftUI

public struct SettingsView: View {
    @ObservedObject var bleManager = BLECentralManager.shared
    @ObservedObject var theme = ThemeManager.shared
    
    @AppStorage("scanModeIndex") private var scanModeIndex = 0
    @AppStorage("cloudAutoSync") private var cloudAutoSync = true
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        StandardHeaderBar(
                            title: "Settings",
                            subtitle: "Preferences & Hardware Config",
                            isScanning: bleManager.isScanning
                        )
                        
                        // Appearance & Theme Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("APPEARANCE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(theme.textSecondaryColor)
                            
                            Toggle(isOn: $theme.isDarkMode) {
                                HStack(spacing: 10) {
                                    Image(systemName: theme.isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                                        .foregroundColor(theme.isDarkMode ? .yellow : .orange)
                                    Text("Dark Mode")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(theme.textPrimaryColor)
                                }
                            }
                            .tint(BleSenseColors.primaryGreen)
                        }
                        .padding(16)
                        .modernCard()
                        
                        // Bluetooth Scanner Configuration
                        VStack(alignment: .leading, spacing: 14) {
                            Text("BLUETOOTH SCAN PARAMETERS")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(theme.textSecondaryColor)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Scan Mode")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(theme.textPrimaryColor)
                                
                                Picker("Scan Mode", selection: $scanModeIndex) {
                                    Text("Low Latency (Fast)").tag(0)
                                    Text("Balanced").tag(1)
                                    Text("Power Saver").tag(2)
                                }
                                .pickerStyle(.segmented)
                            }
                            
                            Divider()
                            
                            Toggle(isOn: $cloudAutoSync) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Dual Cloud Telemetry Sync")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(theme.textPrimaryColor)
                                    Text("Uploads captured packets to Render & Cloudflare endpoints.")
                                        .font(.system(size: 11))
                                        .foregroundColor(theme.textSecondaryColor)
                                }
                            }
                            .tint(BleSenseColors.primaryGreen)
                        }
                        .padding(16)
                        .modernCard()
                        
                        // System Diagnostics & Clearing
                        VStack(alignment: .leading, spacing: 12) {
                            Text("MAINTENANCE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(theme.textSecondaryColor)
                            
                            Button(action: {
                                bleManager.refreshScan()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Restart Bluetooth Scanner")
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.blue)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Divider()
                            
                            Button(action: {
                                bleManager.clearAllData()
                            }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text("Clear All Cached Devices & Packets")
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(16)
                        .modernCard()
                        
                        // App Store & Build Info
                        VStack(alignment: .center, spacing: 6) {
                            Text("BLESense for iOS")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(theme.textPrimaryColor)
                            
                            Text("Version 1.0.0 (Build 1) • App Store Ready")
                                .font(.system(size: 11))
                                .foregroundColor(theme.textSecondaryColor)
                            
                            Text("CoreBluetooth • Swift Charts • Extended Advertisements")
                                .font(.system(size: 10))
                                .foregroundColor(theme.textSecondaryColor.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 80)
                }
            }
            .navigationBarHidden(true)
        }
    }
}
