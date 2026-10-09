//
//  BleDeviceHandler.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Common protocol for isolated BLE device parsing handlers.
//

import Foundation
import CoreBluetooth

public protocol BleDeviceHandler: AnyObject {
    var devices: [BluetoothDeviceModel] { get }
    var historyUpdateTrigger: Date { get }
    
    func canHandle(name: String?, address: String, manufacturerData: Data?) -> Bool
    func handle(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber)
    func clearAllData()
    func getHistory(address: String) -> [HistoricalDataEntry]
}
