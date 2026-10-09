//
//  MainDashboardView.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Main Dashboard view mirroring IntermediateScreen from Android.
//

import SwiftUI

public struct MainDashboardView: View {
    @ObservedObject var bleManager = BLECentralManager.shared
    @ObservedObject var theme = ThemeManager.shared
    
    @State private var navigateToSensorHub = false
    @State private var navigateToStepCounter = false
    @State private var navigateToDataLogger = false
    @State private var navigateToAWS = false
    @State private var navigateToRobot = false
    @State private var navigateToRaw = false
    @State private var navigateToHeroGame = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Top Header with Theme Toggle
                        HStack(alignment: .center, spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(
                                        LinearGradient(colors: [Color(red: 0x38/255.0, green: 0xBD/255.0, blue: 0xF8/255.0),
                                                                Color(red: 0x1D/255.0, green: 0x4E/255.0, blue: 0xD8/255.0)],
                                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 3)
                                
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 4) {
                                    Text("BLE")
                                        .font(.system(size: 22, weight: .black, design: .rounded))
                                        .foregroundColor(theme.textPrimaryColor)
                                    
                                    Text("Sense")
                                        .font(.system(size: 22, weight: .black, design: .rounded))
                                        .foregroundStyle(
                                            LinearGradient(colors: [Color(red: 0x38/255.0, green: 0xBD/255.0, blue: 0xF8/255.0),
                                                                    Color(red: 0x81/255.0, green: 0x8C/255.0, blue: 0xF8/255.0)],
                                                           startPoint: .leading, endPoint: .trailing)
                                        )
                                }
                                
                                Text("Universal IoT Scanner & Controller")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(theme.textSecondaryColor)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation {
                                    theme.isDarkMode.toggle()
                                }
                            }) {
                                Image(systemName: theme.isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(theme.isDarkMode ? Color.yellow : Color.orange)
                                    .frame(width: 38, height: 38)
                                    .background(theme.surfaceColor)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(theme.borderColor, lineWidth: 1))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        // Hero Metric Banner
                        let activeSensors = bleManager.devices.filter { $0.sensorData != nil }.count
                        IntegratedHeroBanner(
                            totalDiscovered: bleManager.devices.count,
                            activeSensors: activeSensors,
                            isScanning: bleManager.isScanning,
                            onToggleScan: {
                                if bleManager.isScanning { bleManager.stopScan() }
                                else { bleManager.startScan() }
                            }
                        )
                        .padding(.horizontal, 16)
                        
                        // Dashboard Navigation Cards
                        VStack(spacing: 12) {
                            NavigationLink(destination: SensorHubView()) {
                                DashboardCard(
                                    icon: "waveform.path.ecg",
                                    iconBg: Color.blue.opacity(0.15),
                                    iconTint: Color.blue,
                                    title: "Sensor Hub",
                                    subtitle: "Discover, connect & monitor nearby BLE sensor pods",
                                    badgeText: "\(bleManager.sensorHubHandler.devices.count) Pods",
                                    badgeColor: Color.blue
                                )
                            }
                            
                            NavigationLink(destination: StepCounterView()) {
                                DashboardCard(
                                    icon: "figure.walk",
                                    iconBg: Color.green.opacity(0.15),
                                    iconTint: Color.green,
                                    title: "Step Counter",
                                    subtitle: "LIS3DH XYZ pedometer & walking dynamics",
                                    badgeText: "Pedometer",
                                    badgeColor: Color.green
                                )
                            }
                            
                            NavigationLink(destination: DataLoggerListView()) {
                                DashboardCard(
                                    icon: "externaldrive.fill",
                                    iconBg: Color.cyan.opacity(0.15),
                                    iconTint: Color.cyan,
                                    title: "LiveStock Logger",
                                    subtitle: "Record, buffer & export high-precision extended logs",
                                    badgeText: "Active Logs",
                                    badgeColor: Color.cyan
                                )
                            }
                            
                            NavigationLink(destination: AWSScannerView()) {
                                DashboardCard(
                                    icon: "cloud.sun.fill",
                                    iconBg: Color.orange.opacity(0.15),
                                    iconTint: Color.orange,
                                    title: "AWS Station",
                                    subtitle: "Autonomous weather station telemetry & solar stats",
                                    badgeText: "AWS Monitor",
                                    badgeColor: Color.orange
                                )
                            }
                            
                            NavigationLink(destination: RobotControlView()) {
                                DashboardCard(
                                    icon: "gamecontroller.fill",
                                    iconBg: Color.purple.opacity(0.15),
                                    iconTint: Color.purple,
                                    title: "Robot Control",
                                    subtitle: "Dual tactile joystick HUD & serial UART commands",
                                    badgeText: "Drive HUD",
                                    badgeColor: Color.purple
                                )
                            }
                            
                            NavigationLink(destination: RawScannerView()) {
                                DashboardCard(
                                    icon: "network",
                                    iconBg: Color.teal.opacity(0.15),
                                    iconTint: Color.teal,
                                    title: "Raw Scanner",
                                    subtitle: "Extended BLE advertising packets & hex inspector",
                                    badgeText: "Raw Bytes",
                                    badgeColor: Color.teal
                                )
                            }
                            
                            NavigationLink(destination: HeroGameView()) {
                                DashboardCard(
                                    icon: "sparkles.tv.fill",
                                    iconBg: Color.pink.opacity(0.15),
                                    iconTint: Color.pink,
                                    title: "Hero Game Zone",
                                    subtitle: "Beacon proximity radar hunt & scavenger challenge",
                                    badgeText: "Play & Hunt",
                                    badgeColor: Color.pink
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 80)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

public struct DashboardCard: View {
    public let icon: String
    public let iconBg: Color
    public let iconTint: Color
    public let title: String
    public let subtitle: String
    public let badgeText: String
    public let badgeColor: Color
    
    @ObservedObject var theme = ThemeManager.shared
    
    public var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(iconBg)
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(iconTint)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(theme.textPrimaryColor)
                    
                    Spacer()
                    
                    Text(badgeText)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(badgeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(badgeColor.opacity(0.12))
                        .clipShape(Capsule())
                }
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(theme.textSecondaryColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(theme.textSecondaryColor.opacity(0.7))
        }
        .padding(14)
        .modernCard()
    }
}
