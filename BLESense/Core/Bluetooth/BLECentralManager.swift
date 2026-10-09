//
//  BLECentralManager.swift
//  BLESense
//
//  Created for BLESense iOS.
//  High-performance CBCentralManager orchestrator managing continuous scanning and routing.
//

import Foundation
import CoreBluetooth
import Combine

public class BLECentralManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    public static let shared = BLECentralManager()
    
    private var centralManager: CBCentralManager!
    
    @Published public var isScanning: Bool = false
    @Published public var bluetoothState: CBManagerState = .unknown
    @Published public var devices: [BluetoothDeviceModel] = []
    @Published public var historyUpdateTrigger: Date = Date()
    
    // Handlers
    public let sensorHubHandler = SensorHubHandler.shared
    public let awsSensorHandler = AwsSensorHandler.shared
    public let dataLoggerHandler = DataLoggerHandler.shared
    public let stepCounterHandler = StepCounterHandler.shared
    public let rawScanHandler = RawScanHandler.shared
    
    private var cancellables = Set<AnyCancellable>()
    private var cachedHandlerRoutes = [String: BleDeviceHandler]()
    private let routeLock = NSLock()
    
    private var scanTimer: Timer?
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(
            delegate: self,
            queue: DispatchQueue(label: "com.blesense.central.queue", qos: .userInitiated),
            options: [CBCentralManagerOptionShowPowerAlertKey: true]
        )
        
        // Combine merged device flows
        Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refreshMergedDevices()
            }
            .store(in: &cancellables)
    }
    
    public func startScan() {
        guard centralManager.state == .poweredOn else {
            print("Cannot start scan: Bluetooth is \(centralManager.state.rawValue)")
            return
        }
        
        let options: [String: Any] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: true
        ]
        
        centralManager.scanForPeripherals(withServices: nil, options: options)
        DispatchQueue.main.async {
            self.isScanning = true
        }
    }
    
    public func stopScan() {
        centralManager.stopScan()
        DispatchQueue.main.async {
            self.isScanning = false
        }
    }
    
    public func refreshScan() {
        stopScan()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.startScan()
        }
    }
    
    public func clearAllData() {
        sensorHubHandler.clearAllData()
        awsSensorHandler.clearAllData()
        dataLoggerHandler.clearAllData()
        stepCounterHandler.clearAllData()
        rawScanHandler.clearAllData()
        routeLock.lock()
        cachedHandlerRoutes.removeAll()
        routeLock.unlock()
        DispatchQueue.main.async {
            self.devices.removeAll()
            self.historyUpdateTrigger = Date()
        }
    }
    
    public func getHistory(address: String) -> [HistoricalDataEntry] {
        let shHistory = sensorHubHandler.getHistory(address: address)
        if !shHistory.isEmpty { return shHistory }
        
        let dlHistory = dataLoggerHandler.getHistory(address: address)
        if !dlHistory.isEmpty { return dlHistory }
        
        let awsHistory = awsSensorHandler.getHistory(address: address)
        if !awsHistory.isEmpty { return awsHistory }
        
        let stepHistory = stepCounterHandler.getHistory(address: address)
        if !stepHistory.isEmpty { return stepHistory }
        
        return rawScanHandler.getHistory(address: address)
    }
    
    // MARK: - CBCentralManagerDelegate
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            self.bluetoothState = central.state
            if central.state == .poweredOn {
                self.startScan()
            } else {
                self.isScanning = false
            }
        }
    }
    
    public func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let address = peripheral.identifier.uuidString
        let name = (advertisementData[CBAdvertisementDataLocalNameKey] as? String) ?? peripheral.name
        let mfgData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
        
        // Fast-path routing
        routeLock.lock()
        let cached = cachedHandlerRoutes[address]
        routeLock.unlock()
        
        if let handler = cached {
            handler.handle(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
            return
        }
        
        // Slow-path discovery
        let handlers: [BleDeviceHandler] = [
            stepCounterHandler,
            dataLoggerHandler,
            awsSensorHandler,
            sensorHubHandler,
            rawScanHandler
        ]
        
        for handler in handlers {
            if handler.canHandle(name: name, address: address, manufacturerData: mfgData) {
                routeLock.lock()
                cachedHandlerRoutes[address] = handler
                routeLock.unlock()
                handler.handle(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
                break
            }
        }
    }
    
    private func refreshMergedDevices() {
        var merged = [BluetoothDeviceModel]()
        merged.append(contentsOf: stepCounterHandler.devices)
        merged.append(contentsOf: dataLoggerHandler.devices)
        merged.append(contentsOf: awsSensorHandler.devices)
        merged.append(contentsOf: sensorHubHandler.devices)
        merged.append(contentsOf: rawScanHandler.devices)
        
        // Deduplicate by address
        var uniqueMap = [String: BluetoothDeviceModel]()
        for dev in merged {
            uniqueMap[dev.address] = dev
        }
        
        let list = Array(uniqueMap.values).sorted { $0.lastSeen > $1.lastSeen }
        if self.devices != list {
            self.devices = list
            self.historyUpdateTrigger = Date()
        }
    }
}
