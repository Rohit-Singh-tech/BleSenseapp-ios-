//
//  RobotConnectionManager.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Robot Car Bluetooth control manager sending real-time ASCII drive commands.
//

import Foundation
import CoreBluetooth

public class RobotConnectionManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    public static let shared = RobotConnectionManager()
    
    private var centralManager: CBCentralManager!
    @Published public var isConnected: Bool = false
    @Published public var isConnecting: Bool = false
    @Published public var activeDeviceName: String = "Not Connected"
    @Published public var driveDirection: String = "STOP"
    @Published public var commandLogs: [String] = []
    @Published public var discoveredRobots: [CBPeripheral] = []
    
    private var connectedPeripheral: CBPeripheral?
    private var txCharacteristic: CBCharacteristic?
    
    // Standard BLE UART Service & TX Characteristic UUIDs (e.g. Nordic UART)
    private let uartServiceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    private let rxCharUUID       = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    private let txCharUUID       = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    
    private var lastSentCommand: String?
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(
            delegate: self,
            queue: DispatchQueue(label: "com.blesense.robot.queue")
        )
    }
    
    public func startRobotScan() {
        guard centralManager.state == .poweredOn else { return }
        discoveredRobots.removeAll()
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    public func connect(to peripheral: CBPeripheral) {
        centralManager.stopScan()
        isConnecting = true
        connectedPeripheral = peripheral
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }
    
    public func disconnect() {
        sendCommand("S")
        if let p = connectedPeripheral {
            centralManager.cancelPeripheralConnection(p)
        }
        connectedPeripheral = nil
        txCharacteristic = nil
        DispatchQueue.main.async {
            self.isConnected = false
            self.isConnecting = false
            self.activeDeviceName = "Not Connected"
        }
    }
    
    public func sendCommand(_ command: String) {
        guard command != lastSentCommand else { return }
        lastSentCommand = command
        
        let logText = "> \(command)"
        DispatchQueue.main.async {
            self.commandLogs.insert(logText, at: 0)
            if self.commandLogs.count > 10 { self.commandLogs.removeLast() }
        }
        
        guard let p = connectedPeripheral, let char = txCharacteristic else { return }
        if let data = command.data(using: .utf8) {
            p.writeValue(data, for: char, type: .withoutResponse)
        }
    }
    
    // MARK: - Drive State Updates
    public func updateDrive(forward: Bool, backward: Bool, left: Bool, right: Bool) {
        var active = [String]()
        if forward && !backward { active.append("F") }
        else if backward && !forward { active.append("B") }
        
        if left && !right { active.append("L") }
        else if right && !left { active.append("R") }
        
        let cmd = active.isEmpty ? "S" : active.joined()
        sendCommand(cmd)
        
        DispatchQueue.main.async {
            self.driveDirection = if forward && left { "FORWARD_LEFT" }
            else if forward && right { "FORWARD_RIGHT" }
            else if backward && left { "BACKWARD_LEFT" }
            else if backward && right { "BACKWARD_RIGHT" }
            else if forward { "FORWARD" }
            else if backward { "BACKWARD" }
            else if left { "LEFT" }
            else if right { "RIGHT" }
            else { "STOP" }
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {}
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        DispatchQueue.main.async {
            if !self.discoveredRobots.contains(where: { $0.identifier == peripheral.identifier }) {
                self.discoveredRobots.append(peripheral)
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            self.isConnected = true
            self.isConnecting = false
            self.activeDeviceName = peripheral.name ?? "Robot Car"
        }
        peripheral.discoverServices([uartServiceUUID])
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = false
            self.isConnecting = false
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = false
            self.isConnecting = false
            self.activeDeviceName = "Not Connected"
        }
    }
    
    // MARK: - CBPeripheralDelegate
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for char in characteristics {
            // Find write-capable characteristic
            if char.properties.contains(.writeWithoutResponse) || char.properties.contains(.write) {
                self.txCharacteristic = char
                break
            }
        }
    }
}
