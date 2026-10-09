//
//  DataLoggerListView.swift
//  BLESense
//
//  Created for BLESense iOS.
//  DataLogger hardware modules catalog mirroring DataLoggerListScreen from Android.
//

import SwiftUI

public struct DataLoggerListView: View {
    @ObservedObject var bleManager = BLECentralManager.shared
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    public init() {}
    
    public var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                StandardHeaderBar(
                    title: "LiveStock Logger",
                    subtitle: "Hardware Module Repository",
                    isScanning: bleManager.isScanning,
                    onBackClick: { presentationMode.wrappedValue.dismiss() }
                )
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Configured Modules (\(DataLoggerRepository.loggers.count) Active)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(theme.textPrimaryColor)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(DataLoggerRepository.loggers) { logger in
                                NavigationLink(destination: DataLoggerControlView(logger: logger)) {
                                    DataLoggerConfigCard(logger: logger)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 60)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

public struct DataLoggerConfigCard: View {
    public let logger: DataLoggerConfig
    @ObservedObject var theme = ThemeManager.shared
    
    public var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.cyan.opacity(0.15))
                    .frame(width: 46, height: 46)
                Image(systemName: "externaldrive.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.cyan)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(logger.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(theme.textPrimaryColor)
                    
                    Spacer()
                    
                    Text("ID \(logger.deviceId)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color.cyan)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.cyan.opacity(0.15))
                        .clipShape(Capsule())
                }
                
                Text(logger.advertiserAddress)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(theme.textSecondaryColor)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(theme.textSecondaryColor.opacity(0.7))
        }
        .padding(14)
        .modernCard()
    }
}
