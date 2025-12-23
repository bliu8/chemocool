# ChemoCool

ChemoCool is a medical device for preventing chemotherapy-induced peripheral neuropathy (CIPN), a painful side effect affecting millions of cancer patients annually. The device uses Peltier modules to maintain cooling at approximately 10°C, which causes vasoconstriction in the hands and feet, preventing chemotherapy drugs from reaching and damaging peripheral nerves.

## iOS Application

The ChemoCool iOS app connects to the device via Bluetooth Low Energy (BLE) to provide real-time temperature monitoring and control.

### Features

- **Real-time Temperature Monitoring**: Displays live temperature readings from the ChemoCool device
- **Bluetooth Connectivity**: Automatically scans for and connects to the ChemoCool device
- **Temperature Display**: Circular progress indicator showing current temperature with visual feedback
- **Unit Conversion**: Toggle between Celsius and Fahrenheit with a tap
- **Intensity Control**: Adjustable intensity slider for device control

### Technical Details

The app is built with SwiftUI and uses CoreBluetooth for BLE communication. It automatically discovers and connects to the ChemoCool device, subscribes to temperature characteristic updates, and displays the data in real time.

### Device Specifications

The ChemoCool device maintains cooling at 10°C, which is above the vasoconstriction threshold of approximately 15°C. This temperature is more tolerable than sub-zero treatments while remaining effective at preventing CIPN. The device is portable, allowing patients to continue cooling treatment beyond hospital visits to outlast the long half-life of chemotherapy drugs.