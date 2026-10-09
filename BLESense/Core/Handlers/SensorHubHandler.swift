//
//  SensorHubHandler.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Isolated handler for Sensor Hub devices (SHT40, LIS3DH, Soil, Ammonia, Sen66, etc.).
//

import Foundation
import CoreBluetooth

public class SensorHubHandler: BleDeviceHandler {
    public static let shared = SensorHubHandler()
    
    public private(set) var devices: [BluetoothDeviceModel] = []
    public private(set) var historyUpdateTrigger: Date = Date()
    
    public var tempLoggerHistory: [String: [TempLoggerData]] = [:]
    public var sen66History: [String: [Sen66Data]] = [:]
    
    private var historicalData: [String: [HistoricalDataEntry]] = [:]
    private let queue = DispatchQueue(label: "com.blesense.sensorhub.queue")
    
    private let sensorHubPatterns = [
        "SHT", "SOIL", "Activity", "LIS3DH", "NH", "Ammonia",
        "sen66", "VEML", "VCNL", "AHT", "BME", "TempLogger", "TLOG", "STS30", "STTS751", "ATRH", "Rain", "Wind"
    ]
    
    public init() {}
    
    public func canHandle(name: String?, address: String, manufacturerData: Data?) -> Bool {
        if address.uppercased() == "DE:AD:BE:AF:BA:11" { return false }
        if let name = name {
            if name.localizedCaseInsensitiveContains("DataLogger") || name.localizedCaseInsensitiveContains("DLOG") { return false }
            if name.localizedCaseInsensitiveContains("Step") { return false }
            for pattern in sensorHubPatterns {
                if name.localizedCaseInsensitiveContains(pattern) { return true }
            }
        }
        return false
    }
    
    public func handle(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        queue.async {
            let address = peripheral.identifier.uuidString
            let name = (advertisementData[CBAdvertisementDataLocalNameKey] as? String) ?? peripheral.name ?? "BLE Sensor Pod"
            let mfgData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
            
            var payload = mfgData ?? Data()
            // If manufacturer data contains company ID (2 bytes), skip prefix if needed
            if payload.count >= 2 {
                let companyId = payload.readUInt16LE(at: 0) ?? 0
                if companyId == 0x0059 && payload.count > 2 {
                    payload = payload.subdata(in: 2..<payload.count)
                }
            }
            
            let deviceType = self.determineDeviceType(name: name)
            guard let sensorData = self.parseSensorPayload(data: payload, type: deviceType, address: address, name: name) else {
                return
            }
            
            let entry = HistoricalDataEntry(
                timestamp: Date(),
                rssi: rssi.intValue,
                sensorData: sensorData,
                rawData: mfgData
            )
            
            var existingHistory = self.historicalData[address] ?? []
            existingHistory.append(entry)
            if existingHistory.count > 500 { existingHistory.removeFirst(existingHistory.count - 500) }
            self.historicalData[address] = existingHistory
            
            let deviceModel = BluetoothDeviceModel(
                name: name,
                rssi: rssi.intValue,
                address: address,
                deviceId: sensorData.deviceId,
                sensorData: sensorData,
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
            self.tempLoggerHistory.removeAll()
            self.sen66History.removeAll()
            self.historyUpdateTrigger = Date()
        }
    }
    
    private func determineDeviceType(name: String) -> String {
        for pattern in sensorHubPatterns {
            if name.localizedCaseInsensitiveContains(pattern) { return pattern }
        }
        return "Unknown"
    }
    
    private func parseSensorPayload(data: Data, type: String, address: String, name: String) -> SensorData? {
        guard !data.isEmpty else { return nil }
        
        switch type {
        case "SHT":
            guard data.count >= 5 else { return nil }
            let temp = Double(Int(data[1])) + Double(data[2]) / 100.0
            let hum = Double(Int(data[3])) + Double(data[4]) / 100.0
            return .sht40(SHT40Data(
                deviceId: String(data[0]),
                temperature: String(format: "%.2f", temp),
                humidity: String(format: "%.2f", hum),
                deviceAddress: address
            ))
            
        case "STS30":
            guard data.count >= 5 else { return nil }
            let tempC = Double(Int(data[1])) + Double(data[2]) / 100.0
            let tempF = Double(Int(data[3])) + Double(data[4]) / 100.0
            return .sts30(STS30Data(
                deviceId: String(data[0]),
                temperatureC: String(format: "%.2f", tempC),
                temperatureF: String(format: "%.2f", tempF),
                deviceAddress: address
            ))
            
        case "STTS751":
            guard data.count >= 5 else { return nil }
            let tempC = Double(Int(data[1])) + Double(data[2]) / 100.0
            let tempF = Double(Int(data[3])) + Double(data[4]) / 100.0
            return .stts751(STTS751Data(
                deviceId: String(data[0]),
                temperatureC: String(format: "%.2f", tempC),
                temperatureF: String(format: "%.2f", tempF),
                deviceAddress: address
            ))
            
        case "ATRH":
            guard data.count >= 9 else { return nil }
            let temp = Double(Int(data[1])) + Double(data[2]) / 100.0
            let hum = Double(Int(data[3])) + Double(data[4]) / 100.0
            let lux = (UInt16(data[5]) << 8) | UInt16(data[6])
            let press = (UInt16(data[7]) << 8) | UInt16(data[8])
            return .atrh(ATRHData(
                deviceId: String(data[0]),
                temperature: String(format: "%.2f", temp),
                humidity: String(format: "%.2f", hum),
                lux: String(lux),
                pressure: String(press),
                deviceAddress: address
            ))
            
        case "Rain":
            guard data.count >= 3 else { return nil }
            let rainfall = Double(Int(data[1])) + Double(data[2]) / 100.0
            return .rain(RainData(
                deviceId: String(data[0]),
                rainfall: String(format: "%.2f", rainfall),
                deviceAddress: address
            ))
            
        case "Wind":
            guard data.count >= 5 else { return nil }
            let speed = Double(Int(data[1])) + Double(data[2]) / 100.0
            let dir = (UInt16(data[3]) << 8) | UInt16(data[4])
            return .wind(WindData(
                deviceId: String(data[0]),
                windSpeed: String(format: "%.2f", speed),
                windDirection: String(dir),
                deviceAddress: address
            ))
            
        case "LIS3DH", "Activity":
            guard data.count >= 7 else { return nil }
            return .lis3dh(LIS3DHData(
                deviceId: String(data[0]),
                x: "\(Int(data[1])).\(data[2])",
                y: "\(Int(data[3])).\(data[4])",
                z: "\(Int(data[5])).\(data[6])",
                deviceAddress: address
            ))
            
        case "SOIL":
            guard data.count >= 16 else { return nil }
            func u(_ idx: Int) -> Int { Int(data[idx]) }
            let nitro = (u(2) << 8) | u(1)
            let phos = (u(4) << 8) | u(3)
            let potas = (u(6) << 8) | u(5)
            let moist = u(7)
            let temp = "\(u(8)).\(u(9))"
            let ec = (u(11) << 8) | u(10)
            let ph = "\(u(12)).\(u(13))"
            let sal = (u(15) << 8) | u(14)
            return .soil(SoilSensorData(
                deviceId: String(u(0)),
                nitrogen: String(nitro),
                phosphorus: String(phos),
                potassium: String(potas),
                moisture: String(moist),
                temperature: temp,
                ec: String(ec),
                pH: ph,
                salinity: String(sal),
                deviceAddress: address
            ))
            
        case "Ammonia", "NH":
            guard data.count >= 6 else { return nil }
            let nh3 = String(format: "%.1f ppm", Float(data[5]))
            return .ammonia(AmmoniaSensorData(
                deviceId: String(data[0]),
                ammonia: nh3,
                rawData: data.hexDump,
                deviceAddress: address
            ))
            
        case "VEML":
            guard data.count >= 3 else { return nil }
            let lux = (UInt16(data[1]) << 8) | UInt16(data[2])
            return .veml7700(VEML7700Data(deviceId: String(data[0]), lux: String(lux), deviceAddress: address))
            
        case "VCNL":
            guard data.count >= 3 else { return nil }
            let lux = (UInt16(data[1]) << 8) | UInt16(data[2])
            return .vcnl4040(VCNL4040Data(deviceId: String(data[0]), lux: String(lux), deviceAddress: address))
            
        case "AHT":
            guard data.count >= 5 else { return nil }
            let temp = Double(Int(data[1])) + Double(data[2]) / 100.0
            let hum = Double(Int(data[3])) + Double(data[4]) / 100.0
            return .aht20(AHT20Data(
                deviceId: String(data[0]),
                temperature: String(format: "%.2f", temp),
                humidity: String(format: "%.2f", hum),
                deviceAddress: address
            ))
            
        case "BME":
            guard data.count >= 7 else { return nil }
            let temp = Double(Int(data[1])) + Double(data[2]) / 100.0
            let hum = Double(Int(data[3])) + Double(data[4]) / 100.0
            let press = (UInt16(data[5]) << 8) | UInt16(data[6])
            return .bme680(BME680Data(
                deviceId: String(data[0]),
                temperature: String(format: "%.2f", temp),
                humidity: String(format: "%.2f", hum),
                pressure: String(press),
                deviceAddress: address
            ))
            
        case "TempLogger", "TLOG":
            guard data.count >= 5 else { return nil }
            let temp = Double(Int(data[1])) + Double(data[2]) / 100.0
            let hum = Double(Int(data[3])) + Double(data[4]) / 100.0
            return .tempLogger(TempLoggerData(
                deviceId: String(data[0]),
                temperature: String(format: "%.2f", temp),
                humidity: String(format: "%.2f", hum),
                rawTemperature: Int(data[1]) * 100 + Int(data[2]),
                rawHumidity: Int(data[3]) * 100 + Int(data[4]),
                rawData: data.hexDump,
                deviceAddress: address,
                timestamp: Date()
            ))
            
        case "sen66":
            guard data.count >= 19 else { return nil }
            let startOffset = (data.count == 19) ? 2 : 0
            func u16(_ idx: Int) -> Int {
                let lIdx = idx - startOffset
                guard lIdx >= 0, lIdx + 1 < data.count else { return 0 }
                return (Int(data[lIdx]) << 8) | Int(data[lIdx + 1])
            }
            func i16(_ idx: Int) -> Int {
                Int(Int16(bitPattern: UInt16(u16(idx))))
            }
            
            let devId = (2 - startOffset >= 0 && 2 - startOffset < data.count) ? String(data[2 - startOffset]) : "1"
            return .sen66(Sen66Data(
                deviceId: devId,
                pm1: String(format: "%.1f", Double(u16(3)) / 10.0),
                pm25: String(format: "%.1f", Double(u16(5)) / 10.0),
                pm4: String(format: "%.1f", Double(u16(7)) / 10.0),
                pm10: String(format: "%.1f", Double(u16(9)) / 10.0),
                temperature: String(format: "%.2f", Double(i16(11)) / 200.0),
                humidity: String(format: "%.2f", Double(i16(13)) / 100.0),
                co2: String(u16(15)),
                voc: String(i16(17)),
                nox: String(i16(19)),
                deviceAddress: address,
                timestamp: Date()
            ))
            
        default:
            return nil
        }
    }
}
