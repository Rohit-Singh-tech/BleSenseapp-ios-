//
//  StepCounterView.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Pedometer interface showing steps, cadence SPM, calories, distance, and motion dynamics.
//

import SwiftUI

public struct StepCounterView: View {
    @ObservedObject var bleManager = BLECentralManager.shared
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isPaused: Bool = false
    
    public init() {}
    
    public var body: some View {
        let handler = bleManager.stepCounterHandler
        let result = handler.latestResult
        let steps = result?.totalSteps ?? 0
        let cadence = result?.cadenceSpm ?? 0
        let distance = result?.distanceMeters ?? 0.0
        let calories = result?.caloriesKcal ?? 0.0
        let isWalking = result?.isWalking ?? false
        
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                StandardHeaderBar(
                    title: "Step Counter",
                    subtitle: "LIS3DH Pedometer Engine",
                    isScanning: bleManager.isScanning,
                    onBackClick: { presentationMode.wrappedValue.dismiss() }
                )
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Circular Step Gauge Card
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .stroke(BleSenseColors.primaryGreen.opacity(0.15), lineWidth: 16)
                                    .frame(width: 190, height: 190)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(min(Double(steps) / 5000.0, 1.0)))
                                    .stroke(
                                        LinearGradient(colors: [BleSenseColors.primaryGreenLight, BleSenseColors.primaryGreen],
                                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                                    )
                                    .frame(width: 190, height: 190)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut, value: steps)
                                
                                VStack(spacing: 4) {
                                    Image(systemName: isWalking ? "figure.walk.motion" : "figure.walk")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(BleSenseColors.primaryGreen)
                                    
                                    Text("\(steps)")
                                        .font(.system(size: 38, weight: .black, design: .rounded))
                                        .foregroundColor(theme.textPrimaryColor)
                                    
                                    Text("TOTAL STEPS")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(theme.textSecondaryColor)
                                }
                            }
                            .padding(.top, 10)
                            
                            // Walking status indicator
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(isWalking ? Color.green : Color.gray)
                                    .frame(width: 8, height: 8)
                                Text(isWalking ? "WALKING DETECTED" : "IDLE / RESTING")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(isWalking ? Color.green : theme.textSecondaryColor)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background((isWalking ? Color.green : Color.gray).opacity(0.12))
                            .clipShape(Capsule())
                        }
                        .padding(20)
                        .modernCard()
                        
                        // Telemetry Grid
                        HStack(spacing: 12) {
                            TelemetryBox(title: "Cadence", value: "\(cadence) SPM", icon: "speedometer", color: .blue)
                            TelemetryBox(title: "Distance", value: String(format: "%.1f m", distance), icon: "figure.walk", color: .orange)
                            TelemetryBox(title: "Calories", value: String(format: "%.1f kcal", calories), icon: "flame.fill", color: .red)
                        }
                        
                        // Control Buttons
                        HStack(spacing: 14) {
                            Button(action: {
                                isPaused = handler.togglePause()
                            }) {
                                HStack {
                                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                    Text(isPaused ? "Resume" : "Pause")
                                }
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(isPaused ? Color.green : Color.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            
                            Button(action: {
                                handler.resetSteps()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Reset")
                                }
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.red)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
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

public struct TelemetryBox: View {
    public let title: String
    public let value: String
    public let icon: String
    public let color: Color
    
    @ObservedObject var theme = ThemeManager.shared
    
    public var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(theme.textPrimaryColor)
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(theme.textSecondaryColor)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .modernCard()
    }
}
