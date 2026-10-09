//
//  DataLoggerHandler.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Triple-blast bundle acquisition protocol (246 bytes/packet, 6 packets/bundle, rounds 1-3).
//

import Foundation
import CoreBluetooth

public class DataLoggerHandler: BleDeviceHandler {
    public static let shared = DataLoggerHandler()
    
    public private(set) var devices: [BluetoothDeviceModel] = []
    public private(set) var historyUpdateTrigger: Date = Date()
    
    public var packetHistory: [String: [DataLoggerData]] = [:]
    public var latestPacket: DataLoggerData?
    
    public var capturedCount: Int = 0
    public var expectedCount: Int = 0
    public var r1Count: Int = 0
    public var r2Count: Int = 0
    public var r3Count: Int = 0
    
    public var selectedDeviceId: String?
    public var selectedAddress: String?
    
    private var historicalData: [String: [HistoricalDataEntry]] = [:]
    private let queue = DispatchQueue(label: "com.blesense.datalogger.queue")
    
    // Tracking bundles and rounds per device
    private class BundleTracker {
        var currentBundleId: Int = -1
        var currentRound: Int = 0
        var lastBundleTime: Date = Date.distantPast
        var firstPacketId: Int = -1
        var receivedIds = Set<Int>()
        var r1Ids = Set<Int>()
        var r2Ids = Set<Int>()
        var r3Ids = Set<Int>()
    }
    
    private var trackers: [String: BundleTracker] = [:]
    
    public init() {}
    
    public func setSelected(deviceId: String?, address: String?) {
        queue.async {
            self.selectedDeviceId = deviceId
            self.selectedAddress = address
        }
    }
    
    public func canHandle(name: String?, address: String, manufacturerData: Data?) -> Bool {
        if let selAddr = selectedAddress, address.caseInsensitiveCompare(selAddr) == .orderedSame {
            return true
        }
        if let name = name {
            if name.localizedCaseInsensitiveContains("DataLogger") || name.localizedCaseInsensitiveContains("DLOG") {
                return true
            }
        }
        if let mfg = manufacturerData, mfg.count >= 240 {
            return true
        }
        return false
    }
    
    public func handle(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        queue.async {
            let address = peripheral.identifier.uuidString
            let name = (advertisementData[CBAdvertisementDataLocalNameKey] as? String) ?? peripheral.name ?? "DataLogger"
            guard let mfgData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data else { return }
            
            var payload = mfgData
            if payload.count >= 2 {
                let companyId = payload.readUInt16LE(at: 0) ?? 0
                if companyId == 0x0059 && payload.count > 2 {
                    payload = payload.subdata(in: 2..<payload.count)
                }
            }
            
            guard payload.count >= 246 else { return }
            
            let packetSize = 246
            let now = Date()
            let tracker = self.trackers[address] ?? {
                let t = BundleTracker()
                self.trackers[address] = t
                return t
            }()
            
            var newParsedPackets = [DataLoggerData]()
            
            for offset in stride(from: 0, to: payload.count, by: packetSize) {
                if offset + packetSize > payload.count { break }
                let slice = payload.subdata(in: offset..<offset + packetSize)
                
                let packetId = Int(slice.readUInt16LE(at: 0) ?? 0)
                let nodeId = Int(slice[2])
                let totalPackets = Int(slice.readUInt16LE(at: 243) ?? 0)
                let bundleId = packetId > 0 ? packetId - ((packetId - 1) % 6) : 0
                
                // Blast Round Detection
                if tracker.currentBundleId != bundleId {
                    tracker.currentBundleId = bundleId
                    tracker.currentRound = 1
                } else {
                    if now.timeIntervalSince(tracker.lastBundleTime) > 0.150 {
                        tracker.currentRound = min(tracker.currentRound + 1, 3)
                    }
                }
                tracker.lastBundleTime = now
                
                if tracker.firstPacketId == -1 && packetId > 0 {
                    tracker.firstPacketId = packetId
                }
                
                switch tracker.currentRound {
                case 1: tracker.r1Ids.insert(packetId)
                case 2: if !tracker.r1Ids.contains(packetId) { tracker.r2Ids.insert(packetId) }
                case 3: if !tracker.r1Ids.contains(packetId) && !tracker.r2Ids.contains(packetId) { tracker.r3Ids.insert(packetId) }
                default: break
                }
                
                let isNew = tracker.receivedIds.insert(packetId).inserted
                
                if isNew {
                    var accelPoints = [(x: Int, y: Int, z: Int)]()
                    for i in stride(from: 3, to: 243, by: 3) {
                        accelPoints.append((x: Int(Int8(bitPattern: slice[i])),
                                           y: Int(Int8(bitPattern: slice[i+1])),
                                           z: Int(Int8(bitPattern: slice[i+2]))))
                    }
                    
                    let packet = DataLoggerData(
                        deviceId: self.selectedDeviceId ?? String(nodeId),
                        currentPacketId: totalPackets,
                        lastPacketId: packetId,
                        timestamp: now,
                        rawData: slice,
                        round: tracker.currentRound,
                        payloadAccel: accelPoints,
                        arrivalTime: now,
                        nodeId: nodeId,
                        bundleId: bundleId,
                        deviceAddress: address
                    )
                    newParsedPackets.append(packet)
                }
            }
            
            guard !newParsedPackets.isEmpty else { return }
            
            let devId = self.selectedDeviceId ?? String(newParsedPackets.first?.nodeId ?? 0)
            var currentList = self.packetHistory[devId] ?? []
            currentList.append(contentsOf: newParsedPackets)
            if currentList.count > 1000 { currentList.removeFirst(currentList.count - 1000) }
            self.packetHistory[devId] = currentList
            
            self.latestPacket = newParsedPackets.last
            self.capturedCount = tracker.receivedIds.count
            self.r1Count = tracker.r1Ids.count
            self.r2Count = tracker.r2Ids.count
            self.r3Count = tracker.r3Ids.count
            
            if let lastPkt = newParsedPackets.last {
                let firstBundleId = tracker.firstPacketId != -1 ? tracker.firstPacketId - ((tracker.firstPacketId - 1) % 6) : 0
                if lastPkt.currentPacketId > 0 && firstBundleId > 0 {
                    self.expectedCount = max(lastPkt.currentPacketId - firstBundleId + 1, 0)
                }
            }
            
            let sensorModel = SensorData.dataLogger(newParsedPackets.last!)
            let entry = HistoricalDataEntry(timestamp: now, rssi: rssi.intValue, sensorData: sensorModel, rawData: mfgData)
            
            var existingHistory = self.historicalData[address] ?? []
            existingHistory.append(entry)
            self.historicalData[address] = existingHistory
            
            let deviceModel = BluetoothDeviceModel(
                name: name,
                rssi: rssi.intValue,
                address: address,
                deviceId: devId,
                sensorData: sensorModel,
                scanRecordBytes: mfgData,
                isConnectable: false,
                lastSeen: now
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
            self.packetHistory.removeAll()
            self.trackers.removeAll()
            self.latestPacket = nil
            self.capturedCount = 0
            self.expectedCount = 0
            self.r1Count = 0
            self.r2Count = 0
            self.r3Count = 0
            self.historyUpdateTrigger = Date()
        }
    }
}
