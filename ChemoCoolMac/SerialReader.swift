//
//  SerialReader.swift
//  ChemoCool
//
//  Created by Ben Liu on 4/13/25.
//

import Foundation

#if os(macOS)
import ORSSerial

class SerialReader: NSObject, ObservableObject, ORSSerialPortDelegate {
    private var serialPort: ORSSerialPort?
    private var buffer: String = ""

    @Published var temperature: Double = 0.0

    override init() {
        super.init()
        let availablePorts = ORSSerialPortManager.shared().availablePorts
        print("🛠 Available ports:")
        for port in availablePorts {
            print(" - \(port.name)  (\(port.path))")
        }
        // Replace this with your actual serial port name from `ls /dev/cu.usb*`
        serialPort = ORSSerialPort(path: "/dev/cu.usbmodem1101")
        serialPort?.baudRate = 9600
        serialPort?.delegate = self
        serialPort?.open()
        
        if serialPort?.isOpen == true {
            print("✅ Serial port opened successfully.")
        } else {
            print("❌ Failed to open serial port.")
        }
    }

    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        if let string = String(data: data, encoding: .utf8) {
            print("Raw serial input: '\(string)'")
            // Append the incoming data to our buffer.
            buffer.append(string)
            
            // Split the buffer on newline to process complete lines
            let lines = buffer.components(separatedBy: "\n")
            
            // Process all complete lines (all except possibly the last incomplete one)
            for i in 0..<lines.count - 1 {
                let trimmed = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
                if let temp = Double(trimmed) {
                    DispatchQueue.main.async {
                        self.temperature = temp
                    }
                } else {
                    print("⚠️ Could not convert '\(trimmed)' to Double.")
                }
            }
            
            // Save the incomplete portion back to the buffer for later processing
            buffer = lines.last ?? ""
        }
    }

    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("Serial port encountered an error: \(error.localizedDescription)")
    }

    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        print("Serial port was removed from system: \(serialPort.path)")
        self.serialPort = nil
    }
}
#else
class SerialReader: ObservableObject {
    @Published var temperature: Double = 0.0
}
#endif
