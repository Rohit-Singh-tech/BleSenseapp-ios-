//
//  AWSDetailView.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Autonomous Weather Station (AWS) telemetry dashboard and diagnostic error flags.
//

import SwiftUI

public struct AWSDetailView: View {
    public let device: BluetoothDeviceModel
    @ObservedObject var bleManager = BLECentralManager.shared
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    public init(device: BluetoothDeviceModel) {
        self.device = device
    }
    
    public var body: some View {
        let history = bleManager.getHistory(address: device.address)
        let awsData: AWSData? = {
            if case let .aws(d) = history.last?.sensorData { return d }
            if case let .aws(d) = device.sensorData { return d }
            return nil
        }()
        
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
                        if let d = awsData {
                            // Primary Weather Grid
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                WeatherMetricCard(title: "Temperature", value: "\(d.temperature) °C", icon: "thermometer.medium", color: .red)
                                WeatherMetricCard(title: "Humidity", value: "\(d.humidity) %", icon: "humidity.fill", color: .blue)
                                WeatherMetricCard(title: "Wind Speed", value: "\(d.windSpeed) m/s", icon: "wind", color: .teal)
                                WeatherMetricCard(title: "Wind Direction", value: "\(d.windDirection) °", icon: "safari.fill", color: .purple)
                                WeatherMetricCard(title: "Rainfall", value: "\(d.rfCumulative) mm", icon: "cloud.rain.fill", color: .indigo)
                                WeatherMetricCard(title: "Signal (RSSI)", value: "\(d.signalStrength) dBm", icon: "antenna.radiowaves.left.and.right", color: .green)
                            }
                            
                            // Power Subsystem Card
                            VStack(alignment: .leading, spacing: 12) {
                                Text("POWER SUBSYSTEM")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(theme.textSecondaryColor)
                                
                                HStack(spacing: 12) {
                                    WeatherMetricCard(title: "Battery Voltage", value: "\(d.batteryVoltage) V", icon: "battery.100.bolt", color: .green)
                                    WeatherMetricCard(title: "Solar Panel", value: "\(d.solarVoltage) V", icon: "sun.max.fill", color: .yellow)
                                }
                            }
                            .padding(16)
                            .modernCard()
                            
                            // Diagnostic Errors
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("DIAGNOSTICS & ERROR FLAGS")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(theme.textSecondaryColor)
                                    Spacer()
                                    Text("\(d.errors.isEmpty ? "All Systems Normal" : "\(d.errors.count) Active Errors")")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(d.errors.isEmpty ? Color.green : Color.red)
                                }
                                
                                if d.errors.isEmpty {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("No hardware errors reported by firmware.")
                                            .font(.system(size: 12))
                                            .foregroundColor(theme.textSecondaryColor)
                                    }
                                    .padding(.top, 4)
                                } else {
                                    ForEach(d.errors, id: \.self) { err in
                                        HStack {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundColor(.red)
                                            Text(err)
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.red)
                                        }
                                        .padding(8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.red.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    }
                                }
                            }
                            .padding(16)
                            .modernCard()
                        } else {
                            Text("Waiting for AWS telemetry advertisement packet...")
                                .font(.system(size: 14))
                                .foregroundColor(theme.textSecondaryColor)
                                .padding(.top, 30)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 60)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

public struct WeatherMetricCard: View {
    public let title: String
    public let value: String
    public let icon: String
    public let color: Color
    @ObservedObject var theme = ThemeManager.shared
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(theme.textPrimaryColor)
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(theme.textSecondaryColor)
        }
        .padding(14)
        .modernCard()
    }
}
