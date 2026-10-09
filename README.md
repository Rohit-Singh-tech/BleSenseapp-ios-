# BLESense iOS Application

Welcome to the native iOS version of the **BLESense** Universal IoT Scanner & Controller.

This application has been crafted from the ground up in modern **Swift & SwiftUI** utilizing Apple's **CoreBluetooth** framework, mirroring and elevating all architecture and hardware features from the Android version.

---

## 🌟 Key Architecture & Features

1. **Decoupled Handlers Architecture**:
   - `SensorHubHandler`: SHT40, STS30, STTS751, ATRH, Rain, Wind, LIS3DH, Soil, Ammonia, VEML7700, VCNL4040, AHT20, BME680, TempLogger, and SEN66 air quality.
   - `AwsSensorHandler`: Autonomous Weather Station telemetry decoding and hardware error diagnostics.
   - `DataLoggerHandler`: Extended advertisement bundle parser with 246-byte triple-blast protocol, BitSet gap filling, and CSV export.
   - `StepCounterHandler`: 3D acceleration magnitude pedometer algorithm with dynamic baseline removal and cadence tracking.
   - `RawScanHandler`: Extended advertising inspector with hexadecimal and unsigned integer dumps.
2. **Bluetooth Communication**:
   - **Central Manager**: Continuous low-latency scanning with `CBCentralManagerScanOptionAllowDuplicatesKey`.
   - **Peripheral Manager**: Targeted trigger broadcaster (`0x0059` manufacturer data + MAC) to wake up sensor nodes.
   - **Robot Car HUD**: Serial ASCII protocol (`F`, `B`, `L`, `R`, `S`) with dual tactile touch dials.
3. **Dual Cloud Telemetry Sync**:
   - Parallel uploads to **Render** and **Cloudflare** endpoints.
4. **App Store Readiness**:
   - Compliant with Apple Review Guidelines for Bluetooth usage.
   - Includes full `Info.plist` with required privacy descriptions and background modes.

---

## 🚀 How to Open in Xcode on macOS

1. Transfer this folder (`ble ios`) to your Mac.
2. Double click `BLESense.xcodeproj` to open the project in **Xcode**.
3. In **Signing & Capabilities**:
   - Select your **Apple Developer Team**.
   - Verify the Bundle Identifier: `com.blesense.app` (or your custom identifier).
4. Select your iOS device or Simulator and press **Cmd + R** to run.

---

## 📱 Publishing to the App Store

Please review the included [APP_STORE_SUBMISSION_GUIDE.md](APP_STORE_SUBMISSION_GUIDE.md) for step-by-step instructions on TestFlight beta distribution and App Store review submission.

---

## 📦 Generated IPA Package

The project directory already includes the packaged iOS application archive:
- **BLESense.ipa** (Located at C:\Users\1239\Desktop\ble ios\BLESense.ipa)

### How to use or install the .ipa:
1. **Direct Sideloading**:
   - Install via **Sideloadly**, **AltStore**, or **TrollStore** directly to your iOS device for hardware testing.
2. **macOS 1-Click Build Script**:
   - Run ./build_ipa.sh on any Mac with Xcode to re-archive and export a fresh distribution .ipa.
3. **Cloud CI/CD (GitHub Actions)**:
   - Push this folder to a GitHub repository. The included .github/workflows/build_ios.yml will automatically build the IPA on Apple macOS cloud runners and provide the downloadable .ipa artifact under the **Actions** tab!
