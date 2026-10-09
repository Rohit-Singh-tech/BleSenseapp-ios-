//
//  RawScannerView.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Extended BLE advertising packet scanner.
//

import SwiftUI

public struct RawScannerView: View {
    @ObservedObject var bleManager = BLECentralManager.shared
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    public init() {}
    
    public var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                StandardHeaderBar(
                    title: "Raw Scanner",
                    subtitle: "Extended BLE Advertisements",
                    isScanning: bleManager.isScanning,
                    onBackClick: { presentationMode.wrappedValue.dismiss() }
                )
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Captured Devices (\(bleManager.rawScanHandler.devices.count))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(theme.textPrimaryColor)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(bleManager.rawScanHandler.devices) { device in
                                NavigationLink(destination: RawDataViewer(device: device)) {
                                    RawDeviceCard(device: device)
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

public struct RawDeviceCard: View {
    public let device: BluetoothDeviceModel
    @ObservedObject var theme = ThemeManager.shared
    
    public var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.teal.opacity(0.15))
                    .frame(width: 46, height: 46)
                Image(systemName: "network")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.teal)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(device.name)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(theme.textPrimaryColor)
                    
                    Spacer()
                    
                    RSSIBadge(rssi: device.rssi)
                }
                
                Text(device.address)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(theme.textSecondaryColor)
                
                let count = device.scanRecordBytes?.count ?? 0
                Text("\(count) raw advertisement bytes")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color.teal)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(theme.textSecondaryColor.opacity(0.7))
        }
        .padding(14)
        .modernCard()
    }
}
