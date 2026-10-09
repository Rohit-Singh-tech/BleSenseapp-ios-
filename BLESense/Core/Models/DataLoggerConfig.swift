//
//  DataLoggerConfig.swift
//  BLESense
//
//  Created for BLESense iOS.
//  DataLogger hardware modules catalog mirroring Android DataLoggerRepository.
//

import Foundation

public struct DataLoggerConfig: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let advertiserAddress: String
    public let deviceId: String
    public let getDataCommand: [UInt8]
    public let resetCommand: [UInt8]

    public init(
        id: String,
        name: String,
        advertiserAddress: String,
        deviceId: String,
        getDataCommand: [UInt8],
        resetCommand: [UInt8]
    ) {
        self.id = id
        self.name = name
        self.advertiserAddress = advertiserAddress
        self.deviceId = deviceId
        self.getDataCommand = getDataCommand
        self.resetCommand = resetCommand
    }
}

public struct DataLoggerRepository {
    public static let loggers: [DataLoggerConfig] = [
        DataLoggerConfig(
            id: "dl1",
            name: "DataLogger 1",
            advertiserAddress: "DE:AD:BE:AF:AA:11",
            deviceId: "11",
            getDataCommand: [0xBB, 0xCC],
            resetCommand: [0xFF, 0xFF]
        ),
        DataLoggerConfig(
            id: "dl2",
            name: "DataLogger 2",
            advertiserAddress: "DE:AD:BE:AF:AA:12",
            deviceId: "12",
            getDataCommand: [0xBC, 0xCD],
            resetCommand: [0xFE, 0xFF]
        ),
        DataLoggerConfig(
            id: "dl3",
            name: "DataLogger 3",
            advertiserAddress: "DE:AD:BE:AF:AA:13",
            deviceId: "13",
            getDataCommand: [0xBD, 0xCE],
            resetCommand: [0xFD, 0xFF]
        ),
        DataLoggerConfig(
            id: "dl4",
            name: "DataLogger 4",
            advertiserAddress: "DE:AD:BE:AF:AA:14",
            deviceId: "14",
            getDataCommand: [0xBE, 0xCF],
            resetCommand: [0xFC, 0xFF]
        ),
        DataLoggerConfig(
            id: "dl5",
            name: "DataLogger 5",
            advertiserAddress: "DE:AD:BE:AF:AA:15",
            deviceId: "15",
            getDataCommand: [0xBF, 0xD0],
            resetCommand: [0xFB, 0xFF]
        ),
        DataLoggerConfig(
            id: "dl6",
            name: "DataLogger 6",
            advertiserAddress: "DE:AD:BE:AF:AA:16",
            deviceId: "16",
            getDataCommand: [0xC0, 0xD1],
            resetCommand: [0xFA, 0xFE]
        ),
        DataLoggerConfig(
            id: "dl7",
            name: "DataLogger 7",
            advertiserAddress: "DE:AD:BE:AF:AA:17",
            deviceId: "17",
            getDataCommand: [0xC1, 0xD2],
            resetCommand: [0xF9, 0xFE]
        )
    ]

    public static func getLoggerById(_ id: String) -> DataLoggerConfig? {
        loggers.first { $0.id == id }
    }

    public static func getLoggerByDeviceId(_ deviceId: String) -> DataLoggerConfig? {
        loggers.first { $0.deviceId == deviceId }
    }
}
