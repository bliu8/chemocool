//
//  ContentView.swift
//  ChemoCoolMac
//
//  Created by Ben Liu on 4/13/25.
//

import SwiftUI
import ORSSerial

struct ContentView: View {
    @StateObject var reader = SerialReader()
    @State private var intensity: CGFloat = 0.5

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.05, green: 0.1, blue: 0.2)
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                    ZStack {
                        // Compute current progress: full circle (360°) represents 100°C
                        let currentProgress = min(CGFloat(reader.temperature / 100.0), 1.0)

                        Circle()
                            .trim(from: 0.0, to: currentProgress)
                            .stroke(style: StrokeStyle(lineWidth: 35, lineCap: .round))
                            .foregroundColor(Color(red: 0.6, green: 0.8, blue: 0.95))
                            .frame(width: 250, height: 250)

                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 35, height: 35)
                                .offset(x: 0, y: -125)
                                .rotationEffect(.degrees(Double(currentProgress) * 360 + 90))
                                .animation(.easeOut(duration: 0.75), value: reader.temperature)
                        }

                        VStack {
                            Image(systemName: "snowflake")
                                .font(.system(size: 30))
                                .foregroundColor(.blue)

                            Text(reader.temperature == 0.0 ? "—" : "\(String(format: "%.1f", reader.temperature))°F")
                                .font(.system(size: 40, weight: .bold))
                                .bold()
                                .foregroundColor(.white)

                            Text("Temperature")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 50)

                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            HStack {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.black)
                                    .frame(width: 24, height: 24)
                                    .background(Color.white)
                                    .clipShape(Circle())

                                Text("Intensity")
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                            }
                            .frame(width: geo.size.width * intensity, height: 80)
                            .padding()
                            .background(Color(red: 0.45, green: 0.55, blue: 1.0))

                            Rectangle()
                                .fill(Color(red: 0.85, green: 0.9, blue: 1.0))
                        }
                        .frame(height: 80)
                        .clipShape(Capsule())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newValue = min(max(0, value.location.x / geo.size.width), 1)
                                    intensity = newValue
                                }
                        )
                    }
                    .frame(height: 80)
                    .padding(.horizontal)
                    .padding(.top, 125)

                    Spacer()
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Temperature Control")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
