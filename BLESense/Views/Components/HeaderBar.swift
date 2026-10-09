//
//  HeaderBar.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Standard top bar header with pulsating live scan status badge.
//

import SwiftUI

public struct StandardHeaderBar: View {
    public let title: String
    public let subtitle: String
    public let isScanning: Bool
    public var onBackClick: (() -> Void)? = nil
    
    @ObservedObject var theme = ThemeManager.shared
    
    public init(title: String, subtitle: String, isScanning: Bool, onBackClick: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.isScanning = isScanning
        self.onBackClick = onBackClick
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if let back = onBackClick {
                Button(action: back) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(theme.textPrimaryColor)
                        .frame(width: 38, height: 38)
                        .background(theme.surfaceColor)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(theme.borderColor, lineWidth: 1))
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(theme.textPrimaryColor)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.textSecondaryColor)
            }
            
            Spacer()
            
            // Live scanning indicator pill
            HStack(spacing: 6) {
                Circle()
                    .fill(isScanning ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                
                Text(isScanning ? "LIVE" : "PAUSED")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isScanning ? Color.green : Color.orange)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                (isScanning ? Color.green : Color.orange).opacity(0.12)
            )
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke((isScanning ? Color.green : Color.orange).opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
