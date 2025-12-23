//
//  ContentView.swift
//  ChemoCool
//
//  Created by Ben Liu on 4/5/25.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @State private var progress: CGFloat = 0.0
    @StateObject var reader = BLEManager()
    @State private var intensity: CGFloat = 0.5
    @State private var isCelsius = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.05, green: 0.1, blue: 0.2)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .trim(from: 0.0, to: progress)
                            .stroke(style: StrokeStyle(lineWidth: 35, lineCap: .round))
                            .foregroundColor(Color(red: 0.6, green: 0.8, blue: 0.95)) // Changed to slightly darker icy blue
                            .rotationEffect(.degrees(0))
                            .frame(width: 250, height: 250)

                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 35, height: 35)
                                .offset(x: 0, y: -125)
                                .rotationEffect(.degrees(Double(progress) * 360 + 90))
                                .animation(.easeOut(duration: 0.75), value: progress)
                        }

                        VStack {
                            Image(systemName: "snowflake")
                                .font(.system(size: 30))
                                .foregroundColor(.blue)
                            
                            Text(reader.temperature > 0.0 && reader.temperature < 100.0 ?
                                 "\(String(format: "%.1f", isCelsius ? reader.temperature : reader.temperature * 9/5 + 32))°\(isCelsius ? "C" : "F")" : "-- °C")
                                .font(.system(size: 40, weight: .bold))
                                .bold()
                                .foregroundColor(.white)
                                .onTapGesture {
                                    isCelsius.toggle()
                                    withAnimation(.easeOut(duration: 0.5)) {
                                        let clampedTemp = max(0.0, min(reader.temperature, 40.0))
                                        progress = CGFloat(clampedTemp / 40.0)
                                    }
                                }
                            
                            Text("Temperature")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 50)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.75)) {
                            let clampedTemp = max(0.0, min(reader.temperature, 40.0))
                            progress = CGFloat(clampedTemp / 40.0)
                        }
                    }
                    .onChange(of: reader.temperature) { newTemp in
                        withAnimation(.easeOut(duration: 0.5)) {
                            let clampedTemp = max(0.0, min(newTemp, 40.0))
                            progress = CGFloat(clampedTemp / 40.0)
                        }
                    }
                    
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
                .toolbar { ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Temperature Control")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 30)
                }
                    
                }
            }
        }
        
    }
}

#Preview {
    ContentView()
}
