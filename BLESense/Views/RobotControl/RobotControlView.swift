//
//  RobotControlView.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Futuristic landscape HUD with dual tactile drive & steering dials and ASCII serial terminal.
//

import SwiftUI
import CoreBluetooth

public struct RobotControlView: View {
    @ObservedObject var robotManager = RobotConnectionManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showDevicePicker = false
    
    // Joystick Touch Offsets
    @State private var driveOffset: CGFloat = 0.0
    @State private var steerOffset: CGFloat = 0.0
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color(red: 0x05/255.0, green: 0x0E/255.0, blue: 0x1A/255.0).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Cyber HUD Bar
                HStack(spacing: 14) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CYBER HUD ROBOT DRIVE")
                            .font(.system(size: 15, weight: .black, design: .monospaced))
                            .foregroundColor(Color(red: 0x42/255.0, green: 0xD8/255.0, blue: 0xFF/255.0))
                        
                        Text("STATUS: \(robotManager.isConnected ? "CONNECTED • \(robotManager.activeDeviceName)" : "DISCONNECTED")")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(robotManager.isConnected ? Color.green : Color.red)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if robotManager.isConnected {
                            robotManager.disconnect()
                        } else {
                            robotManager.startRobotScan()
                            showDevicePicker = true
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: robotManager.isConnected ? "link.badge.plus" : "antenna.radiowaves.left.and.right")
                            Text(robotManager.isConnected ? "Disconnect" : "Connect Robot")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(robotManager.isConnected ? Color.red.opacity(0.8) : Color(red: 0x25/255.0, green: 0x63/255.0, blue: 0xEB/255.0))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(red: 0x07/255.0, green: 0x1A/255.0, blue: 0x2B/255.0))
                
                Spacer()
                
                // Main Dual Tactile Control Deck
                HStack(alignment: .center, spacing: 40) {
                    // Left Control: Vertical Movement Dial (Forward / Backward)
                    VStack(spacing: 8) {
                        Text("FORWARD ^")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0x42/255.0, green: 0xD8/255.0, blue: 0xFF/255.0))
                        
                        ZStack {
                            Circle()
                                .stroke(Color(red: 0x42/255.0, green: 0xD8/255.0, blue: 0xFF/255.0).opacity(0.3), lineWidth: 2)
                                .frame(width: 140, height: 140)
                                .background(Color(red: 0x07/255.0, green: 0x1A/255.0, blue: 0x2B/255.0))
                                .clipShape(Circle())
                            
                            // Interactive Knob
                            Circle()
                                .fill(
                                    RadialGradient(colors: [Color(red: 0x42/255.0, green: 0xD8/255.0, blue: 0xFF/255.0),
                                                           Color(red: 0x02/255.0, green: 0x84/255.0, blue: 0xC7/255.0)],
                                                   center: .center, startRadius: 2, endRadius: 30)
                                )
                                .frame(width: 50, height: 50)
                                .shadow(color: Color(red: 0x42/255.0, green: 0xD8/255.0, blue: 0xFF/255.0).opacity(0.6), radius: 8)
                                .offset(y: driveOffset)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let clamped = max(min(value.translation.height, 45), -45)
                                            driveOffset = clamped
                                            if clamped < -15 {
                                                robotManager.updateDrive(forward: true, backward: false, left: false, right: false)
                                            } else if clamped > 15 {
                                                robotManager.updateDrive(forward: false, backward: true, left: false, right: false)
                                            } else {
                                                robotManager.updateDrive(forward: false, backward: false, left: false, right: false)
                                            }
                                        }
                                        .onEnded { _ in
                                            withAnimation(.spring()) { driveOffset = 0 }
                                            robotManager.updateDrive(forward: false, backward: false, left: false, right: false)
                                        }
                                )
                        }
                        
                        Text("v BACKWARD")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0x42/255.0, green: 0xD8/255.0, blue: 0xFF/255.0))
                    }
                    
                    // Center Terminal & Safety Stop Button
                    VStack(spacing: 12) {
                        Button(action: {
                            robotManager.sendCommand("S")
                        }) {
                            Text("STOP")
                                .font(.system(size: 16, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(width: 80, height: 80)
                                .background(Color.red)
                                .clipShape(Circle())
                                .shadow(color: Color.red.opacity(0.5), radius: 10)
                        }
                        
                        // Active Direction Badge
                        Text(robotManager.driveDirection)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0x42/255.0, green: 0xD8/255.0, blue: 0xFF/255.0))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(red: 0x07/255.0, green: 0x1A/255.0, blue: 0x2B/255.0))
                            .clipShape(Capsule())
                    }
                    
                    // Right Control: Horizontal Steering Dial (Left / Right)
                    VStack(spacing: 8) {
                        Text("< STEER >")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0x42/255.0, green: 0xD8/255.0, blue: 0xFF/255.0))
                        
                        ZStack {
                            Circle()
                                .stroke(Color(red: 0x42/255.0, green: 0xD8/255.0, blue: 0xFF/255.0).opacity(0.3), lineWidth: 2)
                                .frame(width: 140, height: 140)
                                .background(Color(red: 0x07/255.0, green: 0x1A/255.0, blue: 0x2B/255.0))
                                .clipShape(Circle())
                            
                            // Interactive Steering Knob
                            Circle()
                                .fill(
                                    RadialGradient(colors: [Color(red: 0x42/255.0, green: 0xD8/255.0, blue: 0xFF/255.0),
                                                           Color(red: 0x02/255.0, green: 0x84/255.0, blue: 0xC7/255.0)],
                                                   center: .center, startRadius: 2, endRadius: 30)
                                )
                                .frame(width: 50, height: 50)
                                .shadow(color: Color(red: 0x42/255.0, green: 0xD8/255.0, blue: 0xFF/255.0).opacity(0.6), radius: 8)
                                .offset(x: steerOffset)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let clamped = max(min(value.translation.width, 45), -45)
                                            steerOffset = clamped
                                            if clamped < -15 {
                                                robotManager.updateDrive(forward: false, backward: false, left: true, right: false)
                                            } else if clamped > 15 {
                                                robotManager.updateDrive(forward: false, backward: false, left: false, right: true)
                                            } else {
                                                robotManager.updateDrive(forward: false, backward: false, left: false, right: false)
                                            }
                                        }
                                        .onEnded { _ in
                                            withAnimation(.spring()) { steerOffset = 0 }
                                            robotManager.updateDrive(forward: false, backward: false, left: false, right: false)
                                        }
                                )
                        }
                        
                        Text("LEFT / RIGHT")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0x42/255.0, green: 0xD8/255.0, blue: 0xFF/255.0))
                    }
                }
                
                Spacer()
                
                // Bottom Console Log Stream
                VStack(alignment: .leading, spacing: 4) {
                    Text("LIVE COMMAND STREAM")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0x64/255.0, green: 0x74/255.0, blue: 0x8B/255.0))
                    
                    HStack(spacing: 8) {
                        ForEach(robotManager.commandLogs.prefix(5), id: \.self) { cmd in
                            Text(cmd)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0x42/255.0, green: 0xD8/255.0, blue: 0xFF/255.0))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(red: 0x05/255.0, green: 0x0E/255.0, blue: 0x1A/255.0))
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .sheet(isPresented: $showDevicePicker) {
            RobotDevicePickerSheet(isPresented: $showDevicePicker)
        }
        .navigationBarHidden(true)
    }
}

public struct RobotDevicePickerSheet: View {
    @Binding public var isPresented: Bool
    @ObservedObject var robotManager = RobotConnectionManager.shared
    
    public var body: some View {
        NavigationStack {
            List(robotManager.discoveredRobots, id: \.identifier) { peripheral in
                Button(action: {
                    robotManager.connect(to: peripheral)
                    isPresented = false
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(peripheral.name ?? "Unknown Peripheral")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.primary)
                            Text(peripheral.identifier.uuidString)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Select Robot Car")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
}
