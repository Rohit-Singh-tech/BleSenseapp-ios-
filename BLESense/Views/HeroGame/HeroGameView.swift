//
//  HeroGameView.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Superhero beacon radar hunt & scavenger quest mini-game.
//

import SwiftUI

public struct HeroGameView: View {
    @ObservedObject var bleManager = BLECentralManager.shared
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var targetHero = "Iron Man Beacon"
    @State private var score = 120
    @State private var radarSweepAngle: Double = 0.0
    
    public init() {}
    
    public var body: some View {
        ZStack {
            theme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                StandardHeaderBar(
                    title: "Hero Game Zone",
                    subtitle: "BLE Beacon Radar Hunt",
                    isScanning: bleManager.isScanning,
                    onBackClick: { presentationMode.wrappedValue.dismiss() }
                )
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Radar Sweep Animation Screen
                        ZStack {
                            Circle()
                                .stroke(Color.pink.opacity(0.2), lineWidth: 2)
                                .frame(width: 220, height: 220)
                            
                            Circle()
                                .stroke(Color.pink.opacity(0.3), lineWidth: 2)
                                .frame(width: 150, height: 150)
                            
                            Circle()
                                .stroke(Color.pink.opacity(0.4), lineWidth: 2)
                                .frame(width: 80, height: 80)
                            
                            // Radar Scanner Sweep Line
                            Rectangle()
                                .fill(
                                    LinearGradient(colors: [Color.pink, Color.clear], startPoint: .top, endPoint: .bottom)
                                )
                                .frame(width: 2, height: 110)
                                .offset(y: -55)
                                .rotationEffect(.degrees(radarSweepAngle))
                            
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(Color.pink)
                        }
                        .frame(height: 250)
                        .onAppear {
                            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                                radarSweepAngle = 360.0
                            }
                        }
                        
                        // Game Quest Banner
                        VStack(spacing: 8) {
                            Text("TARGET HERO OBJECTIVE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(theme.textSecondaryColor)
                            
                            Text(targetHero)
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(theme.textPrimaryColor)
                            
                            Text("Search nearby BLE beacons! Bring device within -50 dBm proximity.")
                                .font(.system(size: 12))
                                .foregroundColor(theme.textSecondaryColor)
                                .multilineTextAlignment(.center)
                        }
                        .padding(18)
                        .modernCard()
                        
                        // Discovered Nearby Radar Targets
                        VStack(alignment: .leading, spacing: 10) {
                            Text("DISCOVERED BEACONS")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(theme.textSecondaryColor)
                            
                            ForEach(bleManager.devices.prefix(4)) { dev in
                                HStack {
                                    Image(systemName: "bolt.horizontal.fill")
                                        .foregroundColor(Color.pink)
                                    
                                    Text(dev.name)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(theme.textPrimaryColor)
                                    
                                    Spacer()
                                    
                                    RSSIBadge(rssi: dev.rssi)
                                }
                                .padding(10)
                                .background(theme.surfaceLightColor)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
        .navigationBarHidden(true)
    }
}
