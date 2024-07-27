//
//  ContentView.swift
//  KidPaint
//
//  Created by Renning Bruns on 7/27/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var selectedColor: Color = .red
    @State private var points: [CGPoint] = []
    
    var body: some View {
        VStack {
            ColorPicker(selectedColor: $selectedColor)
                .padding()
            
            DrawingView(points: $points, selectedColor: selectedColor)
                .background(Color.white)
                .border(Color.gray, width: 1)
                .padding()
        }
    }
}

struct ColorPicker: View {
    @Binding var selectedColor: Color
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple]

    var body: some View {
        HStack{
            ForEach(colors, id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: selectedColor == color ? 4 : 0)
                    )
                    .onTapGesture {
                        playBubblePopSound()
                        selectedColor = color
                        print("color changed to \(selectedColor)")
                    }
            }
        }
    }
}

struct DrawingView: View {
    @Binding var points: [CGPoint]
    var selectedColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                for point in points {
                    path.addEllipse(in: CGRect(x: point.x, y: point.y, width: 5, height: 5))
                }
            }
            .stroke(selectedColor, lineWidth: 5)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        points.append(value.location)
                    }
            )
        }
    }
}

func playBubblePopSound() {
    let systemSoundID: SystemSoundID = 1104 // Bubble pop sound
    AudioServicesPlaySystemSound(systemSoundID)
}

#Preview {
    ContentView()
}
