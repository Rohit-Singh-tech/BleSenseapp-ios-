//
//  AwsSensorHandler.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Autonomous Weather Station (AWS) telemetry decoder with error bitmask descriptions.
//

import Foundation
import CoreBluetooth

public class AwsSensorHandler: BleDeviceHandler {
    public static let shared = AwsSensorHandler()
    public static let AWS_MAC = "DE:AD:BE:AF:BA:11"
    
    public private(set) var devices: [BluetoothDeviceModel] = []
    public private(set) var historyUpdateTrigger: Date = Date()
    
    private var historicalData: [String: [HistoricalDataEntry]] = [:]
    private let queue = DispatchQueue(label: "com.blesense.aws.queue")
    
    public init() {}
    
    public func canHandle(name: String?, address: String, manufacturerData: Data?) -> Bool {
        return address.uppercased().contains("DE:AD:BE:AF:BA:11") || (name?.localizedCaseInsensitiveContains("AWS") == true)
    }
    
    public func handle(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        queue.async {
            let address = peripheral.identifier.uuidString
            let name = (advertisementData[CBAdvertisementDataLocalNameKey] as? String) ?? peripheral.name ?? "AWS Station"
            guard let mfgData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data else { return }
            
            var payload = mfgData
            if payload.count >= 2 {
                let companyId = payload.readUInt16LE(at: 0) ?? 0
                if companyId == 0x0059 && payload.count > 2 {
                    payload = payload.subdata(in: 2..<payload.count)
                }
            }
            
            guard payload.count >= 12 else { return }
            
            func getInt16(_ idx: Int) -> Int16? {
                guard idx + 1 < payload.count else { return nil }
                return Int16(bitPattern: (UInt16(payload[idx]) << 8) | UInt16(payload[idx + 1]))
            }
            
            let temp = Double(getInt16(0) ?? 0) / 100.0
            let hum = Double(getInt16(2) ?? 0) / 100.0
            let wSpeed = Double(getInt16(4) ?? 0) / 100.0
            let wDir = Double(getInt16(6) ?? 0)
            let rfCum = (payload.count > 8) ? UInt64(payload[8]) : 0
            let devId = (payload.count > 11) ? String(payload[11]) : "1"
            let batt = (payload.count >= 14) ? Double(getInt16(12) ?? 0) / 10.0 : 0.0
            let solar = (payload.count >= 16) ? Double(getInt16(14) ?? 0) / 10.0 : 0.0
            let sigStr = (payload.count > 16) ? String(Int(payload[16]) - 128) : "-70"
            let totalErrors = (payload.count > 30) ? String(payload[30]) : "0"
            
            var errors = [String]()
            for errIdx in 31..<min(payload.count, 47) {
                let code = Int(payload[errIdx])
                if code != 0 {
                    errors.append(self.getBleErrorDescription(code: code))
                }
            }
            
            let awsData = AWSData(
                deviceId: devId,
                temperature: String(format: "%.2f", temp),
                humidity: String(format: "%.2f", hum),
                windSpeed: String(format: "%.2f", wSpeed),
                windDirection: String(format: "%.0f", wDir),
                rfCumulative: String(rfCum),
                batteryVoltage: String(format: "%.2f", batt),
                solarVoltage: String(format: "%.2f", solar),
                signalStrength: sigStr,
                totalErrors: totalErrors,
                errors: errors,
                rawData: payload.hexDump,
                deviceAddress: address
            )
            
            let sensorModel = SensorData.aws(awsData)
            let entry = HistoricalDataEntry(timestamp: Date(), rssi: rssi.intValue, sensorData: sensorModel, rawData: mfgData)
            
            var existingHistory = self.historicalData[address] ?? []
            existingHistory.append(entry)
            if existingHistory.count > 500 { existingHistory.removeFirst(existingHistory.count - 500) }
            self.historicalData[address] = existingHistory
            
            let deviceModel = BluetoothDeviceModel(
                name: name,
                rssi: rssi.intValue,
                address: address,
                deviceId: devId,
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
    
    private func getBleErrorDescription(code: Int) -> String {
        switch code {
        case 0: return "None"
        case 1: return "ATRH Sensor Error"
        case 2: return "Wind Sensor Error"
        case 3: return "Tilt Sensor Error"
        case 4: return "Flash Memory Error"
        case 5: return "Network Connection Error"
        case 6: return "Low Battery Warning"
        case 7: return "Battery Failure"
        case 8: return "Solar Panel Error"
        case 9: return "SD Card Error"
        case 10: return "Rain Gauge Error"
        case 11: return "SIM Card Not Inserted"
        case 21: return "MQTT Connect Error"
        case 22: return "MQTT Upload Error"
        case 23: return "HTTP1 Connect Error"
        case 24: return "HTTP1 Upload Error"
        case 25: return "HTTP2 Connect Error"
        case 26: return "HTTP2 Upload Error"
        default: return "Error code (\(code))"
        }
    }
}
