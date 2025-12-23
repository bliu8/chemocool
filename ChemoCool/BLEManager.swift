import Foundation
import CoreBluetooth

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var temperatureCharacteristic: CBCharacteristic?

    @Published var temperature: Double = 0.0

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("🔍 Scanning for peripherals...")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("⚠️ Bluetooth not available or not authorized.")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("🟢 Discovered peripheral: \(peripheral.name ?? "Unknown")")

        if let name = peripheral.name, name.contains("DSD TECH") {
            print("✅ Connecting to \(name)")
            centralManager.stopScan()
            connectedPeripheral = peripheral
            connectedPeripheral?.delegate = self
            centralManager.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("🔗 Connected to \(peripheral.name ?? "device")")
        peripheral.discoverServices(nil)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.properties.contains(.notify) || characteristic.properties.contains(.read) {
                    temperatureCharacteristic = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                    peripheral.readValue(for: characteristic)
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else {
            print("⚠️ No data received")
            return
        }

        if let string = String(data: data, encoding: .utf8) {
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            //print("📨 Received raw string: '\(trimmed)'")

            let digits = trimmed.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined()

            if let temperature = Double(digits) {
                DispatchQueue.main.async {
                    self.temperature = temperature
                    // print("🌡️ Updated temperature: \(temperature)")
                }
            } else {
                print("⚠️ Could not convert '\(trimmed)' to Double")
            }
        } else {
            let asciiString = data.reduce("") { partialResult, byte in
                partialResult + (byte >= 32 && byte <= 126 ? String(UnicodeScalar(byte)) : "")
            }
            let trimmed = asciiString.trimmingCharacters(in: .whitespacesAndNewlines)
            print("📨 Fallback decoded string: '\(trimmed)'")

            let digits = trimmed.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined()

            if let temperature = Double(digits) {
                DispatchQueue.main.async {
                    self.temperature = temperature
                    //print("🌡️ Updated temperature: \(temperature)")
                }
            } else {
                print("⚠️ Could not convert fallback '\(trimmed)' to Double")
            }
        }
    }
}
