//
//  AWSScannerView.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Autonomous Weather Station (AWS) scanner list.
//

import SwiftUI

public struct AWSScannerView: View {
    @ObservedObject var bleManager = BLECentralManager.shared
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    public init() {}
    
    public var body: some View {
        let awsDevices = bleManager.awsSensorHandler.devices
        
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                StandardHeaderBar(
                    title: "AWS Station",
                    subtitle: "Autonomous Weather Pods",
                    isScanning: bleManager.isScanning,
                    onBackClick: { presentationMode.wrappedValue.dismiss() }
                )
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Discovered Stations (\(awsDevices.count))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(theme.textPrimaryColor)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                        
                        if awsDevices.isEmpty {
                            VStack(spacing: 12) {
                                Spacer()
                                Image(systemName: "cloud.sun.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color.orange.opacity(0.5))
                                Text(bleManager.isScanning ? "Scanning for AWS weather stations..." : "No AWS stations detected")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(theme.textSecondaryColor)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(awsDevices) { device in
                                    NavigationLink(destination: AWSDetailView(device: device)) {
                                        AWSDeviceCard(device: device)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 60)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

public struct AWSDeviceCard: View {
    public let device: BluetoothDeviceModel
    @ObservedObject var theme = ThemeManager.shared
    
    public var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 46, height: 46)
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.orange)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(device.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(theme.textPrimaryColor)
                    
                    Spacer()
                    
                    RSSIBadge(rssi: device.rssi)
                }
                
                Text(device.address)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(theme.textSecondaryColor)
                
                if let data = device.sensorData {
                    Text(data.summary)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.orange)
                        .lineLimit(1)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(theme.textSecondaryColor.opacity(0.7))
        }
        .padding(14)
        .modernCard()
    }
}
