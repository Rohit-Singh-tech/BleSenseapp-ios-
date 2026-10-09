//
//  DataExtensions.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Byte parsing and hexadecimal formatting utilities.
//

import Foundation

public extension Data {
    /// Formats bytes as space-separated hex string (e.g. "01 FF 00 59")
    var hexDump: String {
        map { String(format: "%02X", $0) }.joined(separator: " ")
    }
    
    /// Reads unsigned 16-bit little-endian integer at offset
    func readUInt16LE(at offset: Int) -> UInt16? {
        guard count >= offset + 2 else { return nil }
        return UInt16(self[offset]) | (UInt16(self[offset + 1]) << 8)
    }
    
    /// Reads signed 16-bit little-endian integer at offset
    func readInt16LE(at offset: Int) -> Int16? {
        guard let u = readUInt16LE(at: offset) else { return nil }
        return Int16(bitPattern: u)
    }
    
    /// Reads unsigned 16-bit big-endian integer at offset
    func readUInt16BE(at offset: Int) -> UInt16? {
        guard count >= offset + 2 else { return nil }
        return (UInt16(self[offset]) << 8) | UInt16(self[offset + 1])
    }
    
    /// Reads signed 16-bit big-endian integer at offset
    func readInt16BE(at offset: Int) -> Int16? {
        guard let u = readUInt16BE(at: offset) else { return nil }
        return Int16(bitPattern: u)
    }
}

public extension Array where Element == UInt8 {
    var hexDump: String {
        Data(self).hexDump
    }
}

public extension String {
    /// Converts a MAC address or string into bytes
    func macToBytes() -> [UInt8]? {
        let clean = self.replacingOccurrences(of: ":", with: "")
                        .replacingOccurrences(of: "-", with: "")
        guard clean.count == 12 else { return nil }
        var bytes = [UInt8]()
        var index = clean.startIndex
        for _ in 0..<6 {
            let nextIndex = clean.index(index, offsetBy: 2)
            if let byte = UInt8(clean[index..<nextIndex], radix: 16) {
                bytes.append(byte)
            } else {
                return nil
            }
            index = nextIndex
        }
        return bytes
    }
}
