//
//  SensorData.swift
//  BLESense
//
//  Created for BLESense iOS.
//  Polymorphic sensor data models matching BLESense Android architecture.
//

import Foundation
import SwiftUI

public protocol SensorDataProtocol {
    var deviceId: String { get }
    var deviceAddress: String { get }
    var summary: String { get }
    var sensorTypeTitle: String { get }
}

public enum SensorData: Equatable, Identifiable {
    case sht40(SHT40Data)
    case sts30(STS30Data)
    case stts751(STTS751Data)
    case atrh(ATRHData)
    case rain(RainData)
    case wind(WindData)
    case lis3dh(LIS3DHData)
    case stepCounter(StepCounterData)
    case soil(SoilSensorData)
    case ammonia(AmmoniaSensorData)
    case veml7700(VEML7700Data)
    case vcnl4040(VCNL4040Data)
    case aht20(AHT20Data)
    case bme680(BME680Data)
    case tempLogger(TempLoggerData)
    case aws(AWSData)
    case sen66(Sen66Data)
    case dataLogger(DataLoggerData)

    public var id: String {
        "\(sensorTypeTitle)_\(deviceId)_\(deviceAddress)"
    }

    public var deviceId: String {
        switch self {
        case .sht40(let d): return d.deviceId
        case .sts30(let d): return d.deviceId
        case .stts751(let d): return d.deviceId
        case .atrh(let d): return d.deviceId
        case .rain(let d): return d.deviceId
        case .wind(let d): return d.deviceId
        case .lis3dh(let d): return d.deviceId
        case .stepCounter(let d): return d.deviceId
        case .soil(let d): return d.deviceId
        case .ammonia(let d): return d.deviceId
        case .veml7700(let d): return d.deviceId
        case .vcnl4040(let d): return d.deviceId
        case .aht20(let d): return d.deviceId
        case .bme680(let d): return d.deviceId
        case .tempLogger(let d): return d.deviceId
        case .aws(let d): return d.deviceId
        case .sen66(let d): return d.deviceId
        case .dataLogger(let d): return d.deviceId
        }
    }

    public var deviceAddress: String {
        switch self {
        case .sht40(let d): return d.deviceAddress
        case .sts30(let d): return d.deviceAddress
        case .stts751(let d): return d.deviceAddress
        case .atrh(let d): return d.deviceAddress
        case .rain(let d): return d.deviceAddress
        case .wind(let d): return d.deviceAddress
        case .lis3dh(let d): return d.deviceAddress
        case .stepCounter(let d): return d.deviceAddress
        case .soil(let d): return d.deviceAddress
        case .ammonia(let d): return d.deviceAddress
        case .veml7700(let d): return d.deviceAddress
        case .vcnl4040(let d): return d.deviceAddress
        case .aht20(let d): return d.deviceAddress
        case .bme680(let d): return d.deviceAddress
        case .tempLogger(let d): return d.deviceAddress
        case .aws(let d): return d.deviceAddress
        case .sen66(let d): return d.deviceAddress
        case .dataLogger(let d): return d.deviceAddress
        }
    }

    public var sensorTypeTitle: String {
        switch self {
        case .sht40: return "SHT40"
        case .sts30: return "STS30"
        case .stts751: return "STTS751"
        case .atrh: return "ATRH"
        case .rain: return "Rain"
        case .wind: return "Wind"
        case .lis3dh: return "LIS3DH"
        case .stepCounter: return "Step Counter"
        case .soil: return "Soil Sensor"
        case .ammonia: return "Ammonia Sensor"
        case .veml7700: return "VEML7700"
        case .vcnl4040: return "VCNL4040"
        case .aht20: return "AHT20"
        case .bme680: return "BME680"
        case .tempLogger: return "TempLogger"
        case .aws: return "AWS Station"
        case .sen66: return "SEN66"
        case .dataLogger: return "DataLogger"
        }
    }

    public var summary: String {
        switch self {
        case .sht40(let d): return d.summary
        case .sts30(let d): return d.summary
        case .stts751(let d): return d.summary
        case .atrh(let d): return d.summary
        case .rain(let d): return d.summary
        case .wind(let d): return d.summary
        case .lis3dh(let d): return d.summary
        case .stepCounter(let d): return d.summary
        case .soil(let d): return d.summary
        case .ammonia(let d): return d.summary
        case .veml7700(let d): return d.summary
        case .vcnl4040(let d): return d.summary
        case .aht20(let d): return d.summary
        case .bme680(let d): return d.summary
        case .tempLogger(let d): return d.summary
        case .aws(let d): return d.summary
        case .sen66(let d): return d.summary
        case .dataLogger(let d): return d.summary
        }
    }
}

public struct SHT40Data: Equatable, SensorDataProtocol {
    public let deviceId: String
    public let temperature: String
    public let humidity: String
    public let deviceAddress: String
    public var sensorTypeTitle: String { "SHT40" }
    public var summary: String { "Temp: \(temperature)°C, RH: \(humidity)%" }
}

public struct STS30Data: Equatable, SensorDataProtocol {
    public let deviceId: String
    public let temperatureC: String
    public let temperatureF: String
    public let deviceAddress: String
    public var sensorTypeTitle: String { "STS30" }
    public var summary: String { "Temp: \(temperatureC)°C (\(temperatureF)°F)" }
}

public struct STTS751Data: Equatable, SensorDataProtocol {
    public let deviceId: String
    public let temperatureC: String
    public let temperatureF: String
    public let deviceAddress: String
    public var sensorTypeTitle: String { "STTS751" }
    public var summary: String { "Temp: \(temperatureC)°C (\(temperatureF)°F)" }
}

public struct ATRHData: Equatable, SensorDataProtocol {
    public let deviceId: String
    public let temperature: String
    public let humidity: String
    public let lux: String
    public let pressure: String
    public let deviceAddress: String
    public var sensorTypeTitle: String { "ATRH" }
    public var summary: String { "Temp: \(temperature)°C, RH: \(humidity)%, Lux: \(lux), Press: \(pressure) hPa" }
}

public struct RainData: Equatable, SensorDataProtocol {
    public let deviceId: String
    public let rainfall: String
    public let deviceAddress: String
    public var sensorTypeTitle: String { "Rain Gauge" }
    public var summary: String { "Rainfall: \(rainfall) mm" }
}

public struct WindData: Equatable, SensorDataProtocol {
    public let deviceId: String
    public let windSpeed: String
    public let windDirection: String
    public let deviceAddress: String
    public var sensorTypeTitle: String { "Wind Anemometer" }
    public var summary: String { "Speed: \(windSpeed) m/s, Dir: \(windDirection)°" }
}

public struct LIS3DHData: Equatable, SensorDataProtocol {
    public let deviceId: String
    public let x: String
    public let y: String
    public let z: String
    public let deviceAddress: String
    public var sensorTypeTitle: String { "LIS3DH" }
    public var summary: String { "X: \(x), Y: \(y), Z: \(z)" }
}

public struct StepCounterData: Equatable, SensorDataProtocol {
    public let deviceId: String
    public let totalSteps: Int
    public let isWalking: Bool
    public let cadenceSpm: Int
    public let distanceMeters: Float
    public let caloriesKcal: Float
    public let x: Float
    public let y: Float
    public let z: Float
    public let magnitude: Float
    public let motion: Float
    public let dynamicThreshold: Float
    public let deviceAddress: String
    public let timestamp: Date
    public var sensorTypeTitle: String { "Step Counter" }
    public var summary: String { "\(totalSteps) Steps | \(cadenceSpm) SPM | \(String(format: "%.1f", distanceMeters)) m" }
}

public struct SoilSensorData: Equatable, SensorDataProtocol {
    public let deviceId: String
    public let nitrogen: String
    public let phosphorus: String
    public let potassium: String
    public let moisture: String
    public let temperature: String
    public let ec: String
    public let pH: String
    public let salinity: String
    public let deviceAddress: String
    public var sensorTypeTitle: String { "Soil Sensor" }
    public var summary: String { "Moisture: \(moisture)%, Temp: \(temperature)°C, pH: \(pH), EC: \(ec)" }
}

public struct AmmoniaSensorData: Equatable, SensorDataProtocol {
    public let deviceId: String
    public let ammonia: String
    public let rawData: String
    public let deviceAddress: String
    public var sensorTypeTitle: String { "Ammonia Sensor" }
    public var summary: String { "NH3: \(ammonia)" }
}

public struct VEML7700Data: Equatable, SensorDataProtocol {
    public let deviceId: String
    public let lux: String
    public let deviceAddress: String
    public var sensorTypeTitle: String { "VEML7700" }
    public var summary: String { "Ambient Light: \(lux) Lux" }
}

public struct VCNL4040Data: Equatable, SensorDataProtocol {
    public let deviceId: String
    public let lux: String
    public let deviceAddress: String
    public var sensorTypeTitle: String { "VCNL4040" }
    public var summary: String { "Proximity/Lux: \(lux) Lux" }
}

public struct AHT20Data: Equatable, SensorDataProtocol {
    public let deviceId: String
    public let temperature: String
    public let humidity: String
    public let deviceAddress: String
    public var sensorTypeTitle: String { "AHT20" }
    public var summary: String { "Temp: \(temperature)°C, RH: \(humidity)%" }
}

public struct BME680Data: Equatable, SensorDataProtocol {
    public let deviceId: String
    public let temperature: String
    public let humidity: String
    public let pressure: String
    public let deviceAddress: String
    public var sensorTypeTitle: String { "BME680" }
    public var summary: String { "Temp: \(temperature)°C, RH: \(humidity)%, Press: \(pressure) hPa" }
}

public struct TempLoggerData: Equatable, SensorDataProtocol {
    public let deviceId: String
    public let temperature: String
    public let humidity: String
    public let rawTemperature: Int
    public let rawHumidity: Int
    public let rawData: String
    public let deviceAddress: String
    public let timestamp: Date
    public var sensorTypeTitle: String { "TempLogger" }
    public var summary: String { "Temp: \(temperature)°C, Hum: \(humidity)%" }
}

public struct AWSData: Equatable, SensorDataProtocol {
    public let deviceId: String
    public let temperature: String
    public let humidity: String
    public let windSpeed: String
    public let windDirection: String
    public let rfCumulative: String
    public let batteryVoltage: String
    public let solarVoltage: String
    public let signalStrength: String
    public let totalErrors: String
    public let errors: [String]
    public let rawData: String
    public let deviceAddress: String
    public var sensorTypeTitle: String { "AWS Weather Station" }
    public var summary: String {
        "Temp: \(temperature)°C, RH: \(humidity)%, Wind: \(windSpeed) m/s, Batt: \(batteryVoltage)V"
    }
}

public struct Sen66Data: Equatable, SensorDataProtocol {
    public let deviceId: String
    public let pm1: String
    public let pm25: String
    public let pm4: String
    public let pm10: String
    public let temperature: String
    public let humidity: String
    public let co2: String
    public let voc: String
    public let nox: String
    public let deviceAddress: String
    public let timestamp: Date

    public var sensorTypeTitle: String { "SEN66" }
    public var summary: String {
        "PM2.5: \(pm25) μg/m³, CO₂: \(co2) ppm, Temp: \(temperature)°C, RH: \(humidity)%"
    }

    public var airQualityIndex: String {
        guard let pm = Double(pm25) else { return "Unknown" }
        switch pm {
        case ..<12.0: return "Good"
        case ..<35.4: return "Moderate"
        case ..<55.4: return "Unhealthy (Sensitive)"
        case ..<150.4: return "Unhealthy"
        default: return "Very Unhealthy"
        }
    }

    public var airQualityColor: Color {
        switch airQualityIndex {
        case "Good": return .green
        case "Moderate": return .yellow
        case "Unhealthy (Sensitive)": return .orange
        case "Unhealthy": return .red
        default: return .purple
        }
    }
}

public struct DataLoggerData: Equatable, SensorDataProtocol {
    public let deviceId: String
    public let currentPacketId: Int
    public let lastPacketId: Int
    public let timestamp: Date
    public let rawData: Data
    public let round: Int
    public let payloadAccel: [(x: Int, y: Int, z: Int)]
    public let arrivalTime: Date
    public let nodeId: Int
    public let bundleId: Int
    public let deviceAddress: String

    public var sensorTypeTitle: String { "DataLogger" }
    public var summary: String {
        "Packet: \(lastPacketId)/\(currentPacketId), Round: \(round)"
    }

    public var rawDataHex: String {
        rawData.hexDump
    }

    public static func == (lhs: DataLoggerData, rhs: DataLoggerData) -> Bool {
        return lhs.deviceId == rhs.deviceId &&
            lhs.lastPacketId == rhs.lastPacketId &&
            lhs.currentPacketId == rhs.currentPacketId &&
            lhs.round == rhs.round &&
            lhs.rawData == rhs.rawData
    }
}
