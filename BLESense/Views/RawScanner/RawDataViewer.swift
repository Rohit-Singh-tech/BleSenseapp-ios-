//
//  RawDataViewer.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Raw hexadecimal and integer byte viewer with CSV export.
//

import SwiftUI

public struct RawDataViewer: View {
    public let device: BluetoothDeviceModel
    @ObservedObject var bleManager = BLECentralManager.shared
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var shareURL: URL? = nil
    @State private var showShareSheet: Bool = false
    
    public init(device: BluetoothDeviceModel) {
        self.device = device
    }
    
    public var body: some View {
        let history = bleManager.getHistory(address: device.address)
        let bytes = history.last?.rawData ?? device.scanRecordBytes ?? Data()
        
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                StandardHeaderBar(
                    title: "Raw Packet Inspector",
                    subtitle: device.name,
                    isScanning: bleManager.isScanning,
                    onBackClick: { presentationMode.wrappedValue.dismiss() }
                )
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Device Metadata Card
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("DEVICE METADATA")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(theme.textSecondaryColor)
                                Spacer()
                                RSSIBadge(rssi: device.rssi)
                            }
                            
                            Text(device.address)
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(theme.textPrimaryColor)
                            
                            Text("Total Advertised History: \(history.count) packets")
                                .font(.system(size: 12))
                                .foregroundColor(theme.textSecondaryColor)
                        }
                        .padding(16)
                        .modernCard()
                        
                        // Hexadecimal Dump View
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("HEXADECIMAL DUMP (\(bytes.count) BYTES)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(theme.textSecondaryColor)
                                Spacer()
                            }
                            
                            Text(bytes.isEmpty ? "No payload captured" : bytes.hexDump)
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(BleSenseColors.primaryGreen)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(theme.surfaceLightColor)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .padding(16)
                        .modernCard()
                        
                        // Unsigned Integer Array View
                        VStack(alignment: .leading, spacing: 10) {
                            Text("UNSIGNED INTEGERS (0 - 255)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(theme.textSecondaryColor)
                            
                            Text(bytes.map { String($0) }.joined(separator: ", "))
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(Color.cyan)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(theme.surfaceLightColor)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .padding(16)
                        .modernCard()
                        
                        // Export CSV Button
                        Button(action: {
                            if let url = CSVExporter.shared.exportRawPacketsCSV(entries: history, deviceName: device.name, address: device.address) {
                                shareURL = url
                                showShareSheet = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Captured Packets CSV")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.teal)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 60)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = shareURL {
                ShareSheet(items: [url])
            }
        }
        .navigationBarHidden(true)
    }
}
