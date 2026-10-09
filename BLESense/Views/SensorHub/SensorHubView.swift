//
//  SensorHubView.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Sensor Pods catalog with category filter chips and live telemetry cards.
//

import SwiftUI

public struct SensorHubView: View {
    @ObservedObject var bleManager = BLECentralManager.shared
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedFilter = "All"
    
    private let filterChips = [
        "All", "SHT40", "LIS3DH", "Soil Sensor", "Ammonia Sensor",
        "sen66", "VEML7700", "VCNL4040", "AHT20", "BME680",
        "TempLogger", "STS30", "STTS751", "ATRH", "Rain", "Wind"
    ]
    
    public init() {}
    
    private var filteredDevices: [BluetoothDeviceModel] {
        let list = bleManager.sensorHubHandler.devices
        if selectedFilter == "All" { return list }
        return list.filter { dev in
            switch selectedFilter {
            case "SHT40": return dev.sensorData?.sensorTypeTitle == "SHT40" || dev.name.contains("SHT")
            case "LIS3DH": return dev.sensorData?.sensorTypeTitle == "LIS3DH" || dev.name.contains("LIS3DH") || dev.name.contains("Activity")
            case "Soil Sensor": return dev.sensorData?.sensorTypeTitle == "Soil Sensor" || dev.name.contains("SOIL")
            case "Ammonia Sensor": return dev.sensorData?.sensorTypeTitle == "Ammonia Sensor" || dev.name.contains("NH") || dev.name.contains("Ammonia")
            case "sen66": return dev.sensorData?.sensorTypeTitle == "SEN66" || dev.name.contains("sen66")
            case "VEML7700": return dev.sensorData?.sensorTypeTitle == "VEML7700" || dev.name.contains("VEML")
            case "VCNL4040": return dev.sensorData?.sensorTypeTitle == "VCNL4040" || dev.name.contains("VCNL")
            case "AHT20": return dev.sensorData?.sensorTypeTitle == "AHT20" || dev.name.contains("AHT")
            case "BME680": return dev.sensorData?.sensorTypeTitle == "BME680" || dev.name.contains("BME")
            case "TempLogger": return dev.sensorData?.sensorTypeTitle == "TempLogger" || dev.name.contains("TempLogger") || dev.name.contains("TLOG")
            case "STS30": return dev.sensorData?.sensorTypeTitle == "STS30" || dev.name.contains("STS30")
            case "STTS751": return dev.sensorData?.sensorTypeTitle == "STTS751" || dev.name.contains("STTS")
            case "ATRH": return dev.sensorData?.sensorTypeTitle == "ATRH" || dev.name.contains("ATRH")
            case "Rain": return dev.sensorData?.sensorTypeTitle == "Rain Gauge" || dev.name.contains("Rain")
            case "Wind": return dev.sensorData?.sensorTypeTitle == "Wind Anemometer" || dev.name.contains("Wind")
            default: return true
            }
        }
    }
    
    public var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                StandardHeaderBar(
                    title: "Sensor Hub",
                    subtitle: "Discovered Sensor Pods",
                    isScanning: bleManager.isScanning,
                    onBackClick: { presentationMode.wrappedValue.dismiss() }
                )
                
                // Filter Chips ScrollView
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filterChips, id: \.self) { chip in
                            let isSelected = selectedFilter == chip
                            Button(action: {
                                withAnimation { selectedFilter = chip }
                            }) {
                                Text(chip)
                                    .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(isSelected ? .white : theme.textSecondaryColor)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(isSelected ? BleSenseColors.primaryGreen : theme.surfaceColor)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(isSelected ? Color.clear : theme.borderColor, lineWidth: 1))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                
                // Pods List
                if filteredDevices.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 40))
                            .foregroundColor(theme.textSecondaryColor.opacity(0.6))
                        Text(bleManager.isScanning ? "Scanning for nearby sensor pods..." : "No sensor pods found")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(theme.textSecondaryColor)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredDevices) { device in
                                NavigationLink(destination: SensorDetailView(device: device)) {
                                    SensorPodCard(device: device)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 6)
                        .padding(.bottom, 80)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

public struct SensorPodCard: View {
    public let device: BluetoothDeviceModel
    @ObservedObject var theme = ThemeManager.shared
    
    public var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(BleSenseColors.primaryGreen.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "sensor.tag.radiowaves.forward.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(BleSenseColors.primaryGreen)
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
                
                if let data = device.sensorData {
                    Text(data.summary)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(BleSenseColors.primaryGreen)
                        .padding(.top, 2)
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
