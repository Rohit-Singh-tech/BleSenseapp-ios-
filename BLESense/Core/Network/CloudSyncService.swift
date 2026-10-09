//
//  CloudSyncService.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Dual-cloud remote telemetry uploader (Render & Cloudflare API endpoints).
//

import Foundation

public struct SensorPacketPayload: Codable {
    public let timestamp: Int64
    public let data: [String: String]
    
    public init(timestamp: Int64, data: [String: String]) {
        self.timestamp = timestamp
        self.data = data
    }
}

public class CloudSyncService {
    public static let shared = CloudSyncService()
    
    private let renderBaseURL = "https://ble-sense-rqnu.onrender.com/api/packets"
    private let cloudflareBaseURL = "https://leone-labour-harmony-visiting.trycloudflare.com/api/packets"
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15.0
        self.session = URLSession(configuration: config)
    }
    
    public func uploadDataLoggerBatch(packets: [DataLoggerData], completion: @escaping (Bool) -> Void) {
        guard !packets.isEmpty else {
            completion(false)
            return
        }
        
        let payloads = packets.map { pkt in
            SensorPacketPayload(
                timestamp: Int64(pkt.timestamp.timeIntervalSince1970 * 1000),
                data: [
                    "deviceId": pkt.deviceId,
                    "packetId": String(pkt.lastPacketId),
                    "totalPackets": String(pkt.currentPacketId),
                    "round": String(pkt.round),
                    "rawHex": pkt.rawDataHex
                ]
            )
        }
        
        guard let jsonData = try? JSONEncoder().encode(payloads) else {
            completion(false)
            return
        }
        
        // Dispatch to both endpoints in parallel
        let group = DispatchGroup()
        var successCount = 0
        
        let endpoints = [renderBaseURL, cloudflareBaseURL]
        for urlStr in endpoints {
            guard let url = URL(string: urlStr) else { continue }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = jsonData
            
            group.enter()
            session.dataTask(with: req) { _, response, _ in
                if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                    successCount += 1
                }
                group.leave()
            }.resume()
        }
        
        group.notify(queue: .main) {
            completion(successCount > 0)
        }
    }
}
