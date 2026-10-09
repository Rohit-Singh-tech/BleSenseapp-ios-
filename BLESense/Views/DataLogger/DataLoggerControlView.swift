//
//  DataLoggerControlView.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Triple-blast bundle acquisition control, circular progress, rounds tracking, and CSV export.
//

import SwiftUI

public struct DataLoggerControlView: View {
    public let logger: DataLoggerConfig
    @ObservedObject var bleManager = BLECentralManager.shared
    @ObservedObject var peripheralManager = BLEPeripheralManager.shared
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var shareURL: URL? = nil
    @State private var showShareSheet: Bool = false
    @State private var isUploadingCloud: Bool = false
    @State private var uploadMessage: String? = nil
    
    public init(logger: DataLoggerConfig) {
        self.logger = logger
    }
    
    public var body: some View {
        let handler = bleManager.dataLoggerHandler
        let captured = handler.capturedCount
        let expected = handler.expectedCount
        let progress = expected > 0 ? min(Double(captured) / Double(expected), 1.0) : 0.0
        let packets = handler.packetHistory[logger.deviceId] ?? []
        
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                StandardHeaderBar(
                    title: logger.name,
                    subtitle: "Node ID \(logger.deviceId) | \(logger.advertiserAddress)",
                    isScanning: bleManager.isScanning,
                    onBackClick: { presentationMode.wrappedValue.dismiss() }
                )
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Circular Progress Ring & Acquisition Stats
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .stroke(Color.cyan.opacity(0.15), lineWidth: 14)
                                    .frame(width: 170, height: 170)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(progress))
                                    .stroke(
                                        LinearGradient(colors: [Color.cyan, Color.blue],
                                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                                    )
                                    .frame(width: 170, height: 170)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut, value: progress)
                                
                                VStack(spacing: 2) {
                                    Text("\(Int(progress * 100))%")
                                        .font(.system(size: 34, weight: .black, design: .rounded))
                                        .foregroundColor(theme.textPrimaryColor)
                                    
                                    Text("\(captured) / \(expected)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Color.cyan)
                                    
                                    Text("PACKETS SYNCED")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(theme.textSecondaryColor)
                                }
                            }
                            .padding(.top, 10)
                            
                            // Blast Retry Rounds (R1, R2, R3)
                            HStack(spacing: 10) {
                                RoundPill(title: "Round 1", count: handler.r1Count, color: .green)
                                RoundPill(title: "Round 2", count: handler.r2Count, color: .orange)
                                RoundPill(title: "Round 3", count: handler.r3Count, color: .purple)
                            }
                        }
                        .padding(18)
                        .modernCard()
                        
                        // Control Buttons: Trigger Command Broadcast & Reset
                        HStack(spacing: 12) {
                            Button(action: {
                                handler.setSelected(deviceId: logger.deviceId, address: logger.advertiserAddress)
                                peripheralManager.startTrigger(
                                    command: logger.getDataCommand,
                                    targetAddress: logger.advertiserAddress,
                                    durationSeconds: 10.0
                                )
                            }) {
                                HStack {
                                    Image(systemName: peripheralManager.isAdvertising ? "dot.radiowaves.left.and.right" : "play.fill")
                                    Text(peripheralManager.isAdvertising ? "Broadcasting..." : "Request Data")
                                }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(peripheralManager.isAdvertising ? Color.orange : Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            
                            Button(action: {
                                peripheralManager.startTrigger(
                                    command: logger.resetCommand,
                                    targetAddress: logger.advertiserAddress,
                                    durationSeconds: 3.0
                                )
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Reset Node")
                                }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.red.opacity(0.85))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                        }
                        
                        // CSV & Cloud Upload Actions
                        HStack(spacing: 12) {
                            Button(action: {
                                if let url = CSVExporter.shared.exportDataLoggerCSV(packets: packets, deviceId: logger.deviceId) {
                                    shareURL = url
                                    showShareSheet = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Export CSV (\(packets.count))")
                                }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color.cyan)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.cyan.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.cyan.opacity(0.3), lineWidth: 1))
                            }
                            
                            Button(action: {
                                isUploadingCloud = true
                                CloudSyncService.shared.uploadDataLoggerBatch(packets: packets) { success in
                                    isUploadingCloud = false
                                    uploadMessage = success ? "Cloud sync succeeded!" : "Cloud sync completed with warnings."
                                }
                            }) {
                                HStack {
                                    Image(systemName: isUploadingCloud ? "arrow.triangle.2.circlepath" : "icloud.and.arrow.up.fill")
                                    Text(isUploadingCloud ? "Syncing..." : "Cloud Sync")
                                }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color.purple)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.purple.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.purple.opacity(0.3), lineWidth: 1))
                            }
                        }
                        
                        if let msg = uploadMessage {
                            Text(msg)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.green)
                        }
                        
                        // Captured Packets List
                        VStack(alignment: .leading, spacing: 10) {
                            Text("RECENT PACKET LOGS (\(packets.count))")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(theme.textSecondaryColor)
                            
                            if packets.isEmpty {
                                Text("No packets captured yet. Press 'Request Data' to start extended advertisement dump.")
                                    .font(.system(size: 12))
                                    .foregroundColor(theme.textSecondaryColor)
                                    .padding(.vertical, 10)
                            } else {
                                LazyVStack(spacing: 8) {
                                    ForEach(packets.suffix(15).reversed(), id: \.lastPacketId) { pkt in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Packet #\(pkt.lastPacketId) / \(pkt.currentPacketId)")
                                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                                    .foregroundColor(theme.textPrimaryColor)
                                                
                                                Text("Round \(pkt.round) • Bundle #\(pkt.bundleId)")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(theme.textSecondaryColor)
                                            }
                                            
                                            Spacer()
                                            
                                            Text("80 XYZ Points")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(Color.cyan)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(Color.cyan.opacity(0.12))
                                                .clipShape(Capsule())
                                        }
                                        .padding(10)
                                        .background(theme.surfaceLightColor)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .modernCard()
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
        .onAppear {
            handler.setSelected(deviceId: logger.deviceId, address: logger.advertiserAddress)
        }
        .navigationBarHidden(true)
    }
}

public struct RoundPill: View {
    public let title: String
    public let count: Int
    public let color: Color
    @ObservedObject var theme = ThemeManager.shared
    
    public var body: some View {
        VStack(spacing: 3) {
            Text("\(count)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(theme.textSecondaryColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
