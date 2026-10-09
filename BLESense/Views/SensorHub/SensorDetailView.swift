//
//  SensorDetailView.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Sensor Pod real-time telemetry inspector, raw payload hex viewer, and targeted trigger.
//

import SwiftUI

public struct SensorDetailView: View {
    public let device: BluetoothDeviceModel
    @ObservedObject var bleManager = BLECentralManager.shared
    @ObservedObject var peripheralManager = BLEPeripheralManager.shared
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    public init(device: BluetoothDeviceModel) {
        self.device = device
    }
    
    public var body: some View {
        let history = bleManager.getHistory(address: device.address)
        let latest = history.last?.sensorData ?? device.sensorData
        
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                StandardHeaderBar(
                    title: device.name,
                    subtitle: device.address,
                    isScanning: bleManager.isScanning,
                    onBackClick: { presentationMode.wrappedValue.dismiss() }
                )
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Live Telemetry Banner
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("LIVE TELEMETRY")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(theme.textSecondaryColor)
                                
                                Spacer()
                                
                                RSSIBadge(rssi: device.rssi)
                            }
                            
                            if let data = latest {
                                Text(data.summary)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(theme.textPrimaryColor)
                            } else {
                                Text("Waiting for incoming advertisement payload...")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(theme.textSecondaryColor)
                            }
                        }
                        .padding(16)
                        .modernCard()
                        
                        // Targeted Trigger Broadcast Box
                        VStack(alignment: .leading, spacing: 10) {
                            Text("TARGETED ADVERTISING TRIGGER")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(theme.textSecondaryColor)
                            
                            Text("Broadcast wake-up/request advertisement payload with Company ID 0x0059 and targeted MAC.")
                                .font(.system(size: 12))
                                .foregroundColor(theme.textSecondaryColor)
                            
                            Button(action: {
                                peripheralManager.startTrigger(
                                    command: [0x01, 0x02],
                                    targetAddress: device.address,
                                    durationSeconds: 5.0
                                )
                            }) {
                                HStack {
                                    Image(systemName: peripheralManager.isAdvertising ? "dot.radiowaves.left.and.right" : "paperplane.fill")
                                    Text(peripheralManager.isAdvertising ? "Broadcasting..." : "Broadcast Trigger Command")
                                }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(peripheralManager.isAdvertising ? Color.orange : BleSenseColors.primaryGreen)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                        }
                        .padding(16)
                        .modernCard()
                        
                        // Raw Advertisement Bytes
                        if let bytes = device.scanRecordBytes {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("RAW ADVERTISEMENT BYTES (\(bytes.count) BYTES)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(theme.textSecondaryColor)
                                
                                Text(bytes.hexDump)
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .foregroundColor(BleSenseColors.primaryGreen)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(theme.surfaceLightColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .padding(16)
                            .modernCard()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
