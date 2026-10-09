//
//  MetricCards.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Reusable system metrics banner and RSSI signal badges.
//

import SwiftUI

public struct IntegratedHeroBanner: View {
    public let totalDiscovered: Int
    public let activeSensors: Int
    public let isScanning: Bool
    public var onToggleScan: () -> Void
    
    @ObservedObject var theme = ThemeManager.shared
    
    public init(totalDiscovered: Int, activeSensors: Int, isScanning: Bool, onToggleScan: @escaping () -> Void) {
        self.totalDiscovered = totalDiscovered
        self.activeSensors = activeSensors
        self.isScanning = isScanning
        self.onToggleScan = onToggleScan
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // Scanner status header
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(isScanning ? Color(red: 0x4A/255.0, green: 0xDE/255.0, blue: 0x80/255.0) : Color.yellow)
                        .frame(width: 8, height: 8)
                    
                    Text(isScanning ? "SCANNING ACTIVE" : "SCANNER PAUSED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isScanning ? Color(red: 0x4A/255.0, green: 0xDE/255.0, blue: 0x80/255.0) : Color.yellow)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.blue.opacity(0.15))
                .clipShape(Capsule())
                
                Spacer()
                
                Button(action: onToggleScan) {
                    HStack(spacing: 6) {
                        Image(systemName: isScanning ? "pause.fill" : "play.fill")
                            .font(.system(size: 11, weight: .bold))
                        Text(isScanning ? "Stop" : "Start")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(isScanning ? Color.red : Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            
            // Triple metrics columns
            HStack(spacing: 10) {
                MetricColumn(title: "Discovered", value: "\(totalDiscovered)")
                MetricColumn(title: "Active Pods", value: "\(activeSensors)")
                MetricColumn(title: "Bluetooth", value: isScanning ? "ON" : "OFF", color: isScanning ? Color.green : Color.red)
            }
        }
        .padding(16)
        .modernCard()
    }
}

public struct MetricColumn: View {
    public let title: String
    public let value: String
    public var color: Color? = nil
    
    @ObservedObject var theme = ThemeManager.shared
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(color ?? theme.textPrimaryColor)
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(theme.textSecondaryColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(theme.surfaceLightColor)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(theme.borderColor, lineWidth: 1))
    }
}

public struct RSSIBadge: View {
    public let rssi: Int
    
    public var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 8, weight: .bold))
            Text("\(rssi) dBm")
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(Color(red: 0x06/255.0, green: 0x5F/255.0, blue: 0x46/255.0))
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Color(red: 0xD1/255.0, green: 0xFA/255.0, blue: 0xE5/255.0))
        .clipShape(Capsule())
    }
}

public extension ThemeManager {
    var surfaceLightColor: Color {
        isDarkMode ? BleSenseColors.surfaceLight : Color(red: 0xF8/255.0, green: 0xFA/255.0, blue: 0xFC/255.0)
    }
}
