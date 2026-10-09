//
//  CustomTabBar.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Modern floating navigation bar mirroring BLESense Android ReferenceBottomNavBar.
//

import SwiftUI

public enum AppTab: String, CaseIterable {
    case dashboard = "Dashboard"
    case sensorHub = "Sensors"
    case dataLogger = "Logger"
    case awsStation = "AWS"
    case robotControl = "Robot"
    case settings = "Settings"
    
    public var iconName: String {
        switch self {
        case .dashboard: return "square.grid.2x2.fill"
        case .sensorHub: return "waveform.path.ecg"
        case .dataLogger: return "externaldrive.fill"
        case .awsStation: return "cloud.sun.fill"
        case .robotControl: return "gamecontroller.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

public struct CustomTabBar: View {
    @Binding public var selectedTab: AppTab
    @ObservedObject var theme = ThemeManager.shared
    
    public init(selectedTab: Binding<AppTab>) {
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                let isSelected = selectedTab == tab
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 18, weight: isSelected ? .bold : .regular))
                            .foregroundColor(isSelected ? BleSenseColors.primaryGreen : theme.textSecondaryColor)
                            .scaleEffect(isSelected ? 1.15 : 1.0)
                        
                        Text(tab.rawValue)
                            .font(.system(size: 9, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? BleSenseColors.primaryGreen : theme.textSecondaryColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            theme.surfaceColor.opacity(theme.isDarkMode ? 0.95 : 0.98)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(theme.borderColor, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }
}
