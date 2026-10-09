//
//  CSVExporter.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Telemetry & raw packet export to CSV and iOS UIActivityViewController.
//

import SwiftUI
import UIKit

public struct ShareSheet: UIViewControllerRepresentable {
    public let items: [Any]
    
    public init(items: [Any]) {
        self.items = items
    }
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

public class CSVExporter {
    public static let shared = CSVExporter()
    
    public func exportDataLoggerCSV(packets: [DataLoggerData], deviceId: String) -> URL? {
        let fileName = "DataLogger_\(deviceId)_\(Int(Date().timeIntervalSince1970)).csv"
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        var csvText = "Index,Packet_ID,Total_Packets,Round,Timestamp_Epoch_Ms,Date_Time,Node_ID,Bundle_ID,Payload_Hex\n"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        for (index, packet) in packets.enumerated() {
            let dtStr = formatter.string(from: packet.timestamp)
            let line = "\(index + 1),\(packet.lastPacketId),\(packet.currentPacketId),\(packet.round),\(Int(packet.timestamp.timeIntervalSince1970 * 1000)),\"\(dtStr)\",\(packet.nodeId),\(packet.bundleId),\"\(packet.rawDataHex)\"\n"
            csvText.append(line)
        }
        
        do {
            try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to write CSV: \(error)")
            return nil
        }
    }
    
    public func exportRawPacketsCSV(entries: [HistoricalDataEntry], deviceName: String, address: String) -> URL? {
        let fileName = "RawScan_\(address.replacingOccurrences(of: ":", with: "_"))_\(Int(Date().timeIntervalSince1970)).csv"
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        var csvText = "Index,Timestamp_Epoch_Ms,DateTime,Device_Name,Device_Address,RSSI,Payload_Size,Raw_Hex,Raw_Integer\n"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        for (index, entry) in entries.enumerated() {
            let dtStr = formatter.string(from: entry.timestamp)
            let rawData = entry.rawData ?? Data()
            let hex = rawData.hexDump
            let ints = rawData.map { String($0) }.joined(separator: ", ")
            let line = "\(index + 1),\(Int(entry.timestamp.timeIntervalSince1970 * 1000)),\"\(dtStr)\",\"\(deviceName)\",\"\(address)\",\"\(entry.rssi)\",\(rawData.count),\"\(hex)\",\"\(ints)\"\n"
            csvText.append(line)
        }
        
        do {
            try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to write raw CSV: \(error)")
            return nil
        }
    }
}
