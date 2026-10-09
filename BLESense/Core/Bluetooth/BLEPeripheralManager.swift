//
//  BLEPeripheralManager.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Targeted advertising broadcaster using CBPeripheralManager for trigger commands.
//

import Foundation
import CoreBluetooth

public class BLEPeripheralManager: NSObject, ObservableObject, CBPeripheralManagerDelegate {
    public static let shared = BLEPeripheralManager()
    
    private var peripheralManager: CBPeripheralManager!
    @Published public var isAdvertising: Bool = false
    
    private var stopTimer: Timer?
    private let companyId: UInt16 = 0x0059
    
    private override init() {
        super.init()
        peripheralManager = CBPeripheralManager(
            delegate: self,
            queue: DispatchQueue(label: "com.blesense.peripheral.queue")
        )
    }
    
    public func startTrigger(command: [UInt8], targetAddress: String? = nil, durationSeconds: TimeInterval = 5.0) {
        guard peripheralManager.state == .poweredOn else {
            print("Cannot advertise: PeripheralManager is \(peripheralManager.state.rawValue)")
            return
        }
        
        stopTrigger()
        
        var payload = [UInt8]()
        // Company ID 0x0059 in little endian
        payload.append(UInt8(companyId & 0xFF))
        payload.append(UInt8((companyId >> 8) & 0xFF))
        payload.append(contentsOf: command)
        
        if let mac = targetAddress, let macBytes = mac.macToBytes() {
            payload.append(contentsOf: macBytes)
        }
        
        let data = Data(payload)
        let advertisement: [String: Any] = [
            CBAdvertisementDataManufacturerDataKey: data
        ]
        
        peripheralManager.startAdvertising(advertisement)
        DispatchQueue.main.async {
            self.isAdvertising = true
            self.stopTimer = Timer.scheduledTimer(withTimeInterval: durationSeconds, repeats: false) { [weak self] _ in
                self?.stopTrigger()
            }
        }
    }
    
    public func stopTrigger() {
        DispatchQueue.main.async {
            self.stopTimer?.invalidate()
            self.stopTimer = nil
            self.isAdvertising = false
        }
        peripheralManager.stopAdvertising()
    }
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("PeripheralManager state: \(peripheral.state.rawValue)")
    }
    
    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("Failed to start advertising: \(error)")
            DispatchQueue.main.async { self.isAdvertising = false }
        } else {
            print("Targeted advertising active!")
        }
    }
}
