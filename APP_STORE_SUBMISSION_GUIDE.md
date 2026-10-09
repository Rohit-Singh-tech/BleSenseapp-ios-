# BLESense iOS - App Store Submission Guide

This guide details the step-by-step instructions to distribute and publish **BLESense** on the Apple App Store.

---

## 1. Prerequisites
- An active **Apple Developer Program** account ($99/year).
- A Mac running **Xcode 15+** or **Xcode 16+**.
- Physical iOS device with Bluetooth enabled for hardware verification.

---

## 2. Xcode Project Configuration
1. Open `BLESense.xcodeproj` in Xcode.
2. Select the top-level **BLESense** project in the navigator.
3. Under the **Signing & Capabilities** tab:
   - Check **Automatically manage signing**.
   - Select your **Team**.
   - Ensure the Bundle Identifier is unique (e.g., `com.yourcompany.blesense`).
4. Under **General**:
   - Deployment Target: **iOS 16.0** or later.
   - Version: `1.0.0`
   - Build: `1`

---

## 3. Bluetooth Privacy Declarations (Info.plist)
Apple strictly enforces clear, user-facing explanations for Bluetooth usage. The project already includes:
- **`NSBluetoothAlwaysUsageDescription`**:
  > *"BLESense requires Bluetooth access to discover, connect, and read telemetry from environmental sensor pods, weather stations, and hardware data loggers."*
- **`NSBluetoothPeripheralUsageDescription`**:
  > *"BLESense uses Bluetooth advertising to broadcast targeted wake-up and trigger commands to nearby sensor pods."*

---

## 4. App Store Connect Setup
1. Log in to [App Store Connect](https://appstoreconnect.apple.com).
2. Go to **Apps** > **+** > **New App**.
3. Select **iOS**, enter **BLESense**, select your primary language, and choose your Bundle ID.
4. Fill in:
   - **Subtitle**: IoT Sensor Pods & Weather Monitor
   - **Category**: Utilities / Weather
   - **Privacy Policy URL**: Link to your privacy policy describing BLE usage.

---

## 5. Archiving & Submitting Build
1. In Xcode, set the run destination to **Any iOS Device (arm64)**.
2. Go to **Product** > **Archive**.
3. Once archiving completes in the Organizer window:
   - Click **Distribute App**.
   - Choose **App Store Connect**.
   - Click **Upload** and follow the prompts.
4. After upload, the build will appear under **TestFlight** within 10-15 minutes.

---

## 6. Tips for Apple App Review Approval
- **Hardware Demo Video**: Because BLESense connects to external BLE hardware, provide a short 30-second YouTube or Vimeo link in **App Review Information -> Notes** showing the app discovering and displaying sensor data.
- **Review Notes**: Explain that the app requires physical BLE peripherals transmitting standard sensor advertisements.
