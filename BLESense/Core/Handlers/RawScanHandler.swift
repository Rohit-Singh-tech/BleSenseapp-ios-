//
//  RawScanHandler.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Diagnostic raw packet inspector capturing extended BLE advertisements.
//

import Foundation
import CoreBluetooth

public class RawScanHandler: BleDeviceHandler {
    public static let shared = RawScanHandler()
    
    public private(set) var devices: [BluetoothDeviceModel] = []
    public private(set) var historyUpdateTrigger: Date = Date()
    
    private var historicalData: [String: [HistoricalDataEntry]] = [:]
    private let queue = DispatchQueue(label: "com.blesense.rawscan.queue")
    
    public init() {}
    
    public func canHandle(name: String?, address: String, manufacturerData: Data?) -> Bool {
        return true // Fallback handler for all BLE devices
    }
    
    public func handle(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        queue.async {
            let address = peripheral.identifier.uuidString
            let name = (advertisementData[CBAdvertisementDataLocalNameKey] as? String) ?? peripheral.name ?? "Raw BLE Device"
            let mfgData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
            
            let entry = HistoricalDataEntry(timestamp: Date(), rssi: rssi.intValue, sensorData: nil, rawData: mfgData)
            
            var existingHistory = self.historicalData[address] ?? []
            existingHistory.append(entry)
            if existingHistory.count > 500 { existingHistory.removeFirst(existingHistory.count - 500) }
            self.historicalData[address] = existingHistory
            
            let deviceModel = BluetoothDeviceModel(
                name: name,
                rssi: rssi.intValue,
                address: address,
                deviceId: "N/A",
                sensorData: nil,
                scanRecordBytes: mfgData,
                isConnectable: (advertisementData[CBAdvertisementDataIsConnectable] as? NSNumber)?.boolValue ?? false,
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
    
    public func getHistory(address: String) -> [HistoricalDataEntry] {
        queue.sync { historicalData[address] ?? [] }
    }
    
    public func clearAllData() {
        queue.async {
            self.devices.removeAll()
            self.historicalData.removeAll()
            self.historyUpdateTrigger = Date()
        }
    }
}
