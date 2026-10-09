//
//  StepCounter.swift
//  BLESense
//
//  Created for BLESense iOS.
//  High-accuracy, pocket-optimized pedometer algorithm ported from Android.
//

import Foundation

public struct StepResult: Equatable {
    public let totalSteps: Int
    public let isWalking: Bool
    public let cadenceSpm: Int
    public let distanceMeters: Float
    public let caloriesKcal: Float
    public let currentMagnitude: Float
    public let currentMotion: Float
    public let dynamicThreshold: Float
    public let lastStepTimeMs: Int64
    public let sampleTimestampMs: Int64
}

public class StepCounter {
    private let minStepIntervalMs: Int64 = 260
    private let idleTimeoutMs: Int64 = 2500

    public private(set) var totalSteps: Int = 0
    public private(set) var isWalking: Bool = false
    public private(set) var cadenceSpm: Int = 0
    public var isPaused: Bool = false

    private var lastSampleTimestamp: Int64 = 0
    private var baseline: Float = 0.0
    private var smoothedMotion: Float = 0.0

    private var isAbovePeak: Bool = false
    private var peakValue: Float = 0.0
    private var peakTimeMs: Int64 = 0
    private var lastStepTimeMs: Int64 = 0

    public private(set) var latestResult: StepResult?

    public init() {}

    public func addSample(timestampMs: Int64, x: Float, y: Float, z: Float) -> StepResult {
        let magnitude = sqrt(x * x + y * y + z * z)

        if isPaused {
            let res = buildResult(magnitude: magnitude, motion: 0, threshold: 0.45, timestampMs: timestampMs)
            latestResult = res
            return res
        }

        let dt = lastSampleTimestamp != 0 ? max(timestampMs - lastSampleTimestamp, 10) : 50
        lastSampleTimestamp = timestampMs

        // Dynamic Gravity Baseline Removal
        if baseline == 0 || dt > 3000 {
            baseline = magnitude
            smoothedMotion = 0
            isAbovePeak = false
            peakValue = 0
        } else {
            let alpha: Float = 0.94
            baseline = alpha * baseline + (1.0 - alpha) * magnitude
        }

        let rawMotion = magnitude - baseline
        smoothedMotion = 0.60 * smoothedMotion + 0.40 * rawMotion

        let upperThreshold: Float = 0.45
        let lowerThreshold: Float = 0.10

        if !isAbovePeak {
            if smoothedMotion > upperThreshold {
                isAbovePeak = true
                peakValue = smoothedMotion
                peakTimeMs = timestampMs
            }
        } else {
            if smoothedMotion > peakValue {
                peakValue = smoothedMotion
            }

            let hasFallen = (smoothedMotion <= lowerThreshold) || (smoothedMotion <= peakValue * 0.45)

            if hasFallen {
                let peakProminence = peakValue - smoothedMotion
                let timeSinceLast = lastStepTimeMs > 0 ? timestampMs - lastStepTimeMs : minStepIntervalMs

                if peakProminence >= 0.35 && timeSinceLast >= minStepIntervalMs {
                    totalSteps += 1
                    lastStepTimeMs = timestampMs
                    isWalking = true

                    if timeSinceLast >= minStepIntervalMs && timeSinceLast <= 2500 {
                        updateCadence(intervalMs: timeSinceLast)
                    }
                }
                isAbovePeak = false
            } else if timestampMs - peakTimeMs > 2000 {
                isAbovePeak = false
            }
        }

        if lastStepTimeMs > 0 && (timestampMs - lastStepTimeMs > idleTimeoutMs) {
            isWalking = false
            cadenceSpm = 0
        }

        let result = buildResult(magnitude: magnitude, motion: smoothedMotion, threshold: upperThreshold, timestampMs: timestampMs)
        latestResult = result
        return result
    }

    private func updateCadence(intervalMs: Int64) {
        guard intervalMs > 0 else { return }
        let rawCadence = Int(min(max(60000.0 / Double(intervalMs), 40), 220))
        if cadenceSpm == 0 {
            cadenceSpm = rawCadence
        } else {
            cadenceSpm = Int(0.65 * Float(cadenceSpm) + 0.35 * Float(rawCadence))
        }
    }

    public func reset() {
        totalSteps = 0
        isWalking = false
        cadenceSpm = 0
        baseline = 0
        smoothedMotion = 0
        isAbovePeak = false
        peakValue = 0
        peakTimeMs = 0
        lastSampleTimestamp = 0
        lastStepTimeMs = 0
        latestResult = buildResult(magnitude: 0, motion: 0, threshold: 0.45, timestampMs: Int64(Date().timeIntervalSince1970 * 1000))
    }

    private func buildResult(magnitude: Float, motion: Float, threshold: Float, timestampMs: Int64) -> StepResult {
        return StepResult(
            totalSteps: totalSteps,
            isWalking: isWalking,
            cadenceSpm: cadenceSpm,
            distanceMeters: Float(totalSteps) * 0.75,
            caloriesKcal: Float(totalSteps) * 0.04,
            currentMagnitude: magnitude,
            currentMotion: motion,
            dynamicThreshold: threshold,
            lastStepTimeMs: lastStepTimeMs,
            sampleTimestampMs: timestampMs
        )
    }
}
