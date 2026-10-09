//
//  StepCounterHandler.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Pedometer handler feeding real-time LIS3DH accelerometer streams to StepCounter engine.
//

import Foundation
import CoreBluetooth

public class StepCounterHandler: BleDeviceHandler {
    public static let shared = StepCounterHandler()
    
    public private(set) var devices: [BluetoothDeviceModel] = []
    public private(set) var historyUpdateTrigger: Date = Date()
    
    public private(set) var latestResult: StepResult?
    public var selectedAddress: String?
    
    private var engines: [String: StepCounter] = [:]
    private var historicalData: [String: [HistoricalDataEntry]] = [:]
    private let queue = DispatchQueue(label: "com.blesense.stepcounter.queue")
    
    public init() {}
    
    public func canHandle(name: String?, address: String, manufacturerData: Data?) -> Bool {
        guard let name = name else { return false }
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return clean.contains("step counter") || clean.contains("stepcounter") || clean.contains("step_counter") || clean.hasPrefix("step")
    }
    
    public func handle(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        queue.async {
            let address = peripheral.identifier.uuidString
            let name = (advertisementData[CBAdvertisementDataLocalNameKey] as? String) ?? peripheral.name ?? "Step Counter"
            guard let mfgData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data else { return }
            
            var payload = mfgData
            if payload.count >= 2 {
                let companyId = payload.readUInt16LE(at: 0) ?? 0
                if companyId == 0x0059 && payload.count > 2 {
                    payload = payload.subdata(in: 2..<payload.count)
                }
            }
            
            guard payload.count >= 7 else { return }
            
            let nodeId = String(payload[0])
            func parseAxis(intByte: UInt8, fracByte: UInt8) -> Float {
                let i = Int8(bitPattern: intByte)
                let f = Float(fracByte) / 100.0
                return i < 0 ? Float(i) - f : Float(i) + f
            }
            
            let x = parseAxis(intByte: payload[1], fracByte: payload[2])
            let y = parseAxis(intByte: payload[3], fracByte: payload[4])
            let z = parseAxis(intByte: payload[5], fracByte: payload[6])
            
            let engine = self.engines[address] ?? {
                let e = StepCounter()
                self.engines[address] = e
                return e
            }()
            
            let nowMs = Int64(Date().timeIntervalSince1970 * 1000)
            let result = engine.addSample(timestampMs: nowMs, x: x, y: y, z: z)
            
            if self.selectedAddress == nil || self.selectedAddress == address {
                self.selectedAddress = address
                self.latestResult = result
            }
            
            let stepData = StepCounterData(
                deviceId: nodeId,
                totalSteps: result.totalSteps,
                isWalking: result.isWalking,
                cadenceSpm: result.cadenceSpm,
                distanceMeters: result.distanceMeters,
                caloriesKcal: result.caloriesKcal,
                x: x,
                y: y,
                z: z,
                magnitude: result.currentMagnitude,
                motion: result.currentMotion,
                dynamicThreshold: result.dynamicThreshold,
                deviceAddress: address,
                timestamp: Date()
            )
            
            let sensorModel = SensorData.stepCounter(stepData)
            let entry = HistoricalDataEntry(timestamp: Date(), rssi: rssi.intValue, sensorData: sensorModel, rawData: mfgData)
            
            var existingHistory = self.historicalData[address] ?? []
            existingHistory.append(entry)
            if existingHistory.count > 500 { existingHistory.removeFirst(existingHistory.count - 500) }
            self.historicalData[address] = existingHistory
            
            let deviceModel = BluetoothDeviceModel(
                name: name,
                rssi: rssi.intValue,
                address: address,
                deviceId: nodeId,
                sensorData: sensorModel,
                scanRecordBytes: mfgData,
                isConnectable: false,
                lastSeen: Date()
            )
            
            if let index = self.devices.firstIndex(where: { $0.address == address }) {
                self.devices[index] = deviceModel
            } else {
                self.devices.append(deviceModel)
            }
            
            self.historyUpdateTrigger = Date()
        }
    }
    
    public func resetSteps() {
        queue.async {
            self.engines.values.forEach { $0.reset() }
            self.latestResult = nil
            self.historyUpdateTrigger = Date()
        }
    }
    
    public func togglePause() -> Bool {
        queue.sync {
            guard let addr = selectedAddress, let engine = engines[addr] else { return false }
            engine.isPaused.toggle()
            return engine.isPaused
        }
    }
    
    public func getHistory(address: String) -> [HistoricalDataEntry] {
        queue.sync { historicalData[address] ?? [] }
    }
    
    public func clearAllData() {
        queue.async {
            self.devices.removeAll()
            self.historicalData.removeAll()
            self.engines.removeAll()
            self.latestResult = nil
            self.historyUpdateTrigger = Date()
        }
    }
}
