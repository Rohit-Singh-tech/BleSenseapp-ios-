//
//  BluetoothDeviceModel.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Model representing discovered BLE peripherals and telemetry history.
//

import Foundation

public struct BluetoothDeviceModel: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let rssi: Int
    public let address: String
    public let deviceId: String
    public var sensorData: SensorData?
    public var scanRecordBytes: Data?
    public let isConnectable: Bool
    public var lastSeen: Date

    public init(
        name: String,
        rssi: Int,
        address: String,
        deviceId: String,
        sensorData: SensorData? = nil,
        scanRecordBytes: Data? = nil,
        isConnectable: Bool = false,
        lastSeen: Date = Date()
    ) {
        self.id = address
        self.name = name.isEmpty ? "BLE Sensor Pod" : name
        self.rssi = rssi
        self.address = address
        self.deviceId = deviceId
        self.sensorData = sensorData
        self.scanRecordBytes = scanRecordBytes
        self.isConnectable = isConnectable
        self.lastSeen = lastSeen
    }

    public static func == (lhs: BluetoothDeviceModel, rhs: BluetoothDeviceModel) -> Bool {
        return lhs.address == rhs.address &&
            lhs.rssi == rhs.rssi &&
            lhs.sensorData == rhs.sensorData &&
            lhs.lastSeen == rhs.lastSeen
    }
}

public struct HistoricalDataEntry: Identifiable, Equatable {
    public let id = UUID()
    public let timestamp: Date
    public let rssi: Int
    public let sensorData: SensorData?
    public let rawData: Data?

    public init(timestamp: Date = Date(), rssi: Int = -60, sensorData: SensorData?, rawData: Data? = nil) {
        self.timestamp = timestamp
        self.rssi = rssi
        self.sensorData = sensorData
        self.rawData = rawData
    }
}
