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

struct DrawingPath: Identifiable {
    let id = UUID()
    var color: Color = .red
    var points: [CGPoint] = []
}

struct DrawingView: View {
    @Binding var points: [CGPoint]
    var selectedColor: Color
    @State private var isDragging: Bool = false
    
    @State private var paths: [DrawingPath] = []
    @State private var currentPath = DrawingPath()
    
    var body: some View {
        Canvas { context, size in
            for path in paths {
                var drawingPath = Path()
                if let firstPoint = path.points.first {
                    drawingPath.move(to: firstPoint)
                    for point in path.points.dropFirst() {
                        drawingPath.addLine(to: point)
                    }
                }
                context.stroke(drawingPath, with: .color(path.color), lineWidth: 40)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    currentPath.points.append(value.location)
                }
                .onEnded { _ in
                    currentPath.color = selectedColor
                    paths.append(currentPath)
                    currentPath = DrawingPath()
                }
        )
    }
}

func playBubblePopSound() {
    let systemSoundID: SystemSoundID = 1104 // Bubble pop sound
    AudioServicesPlaySystemSound(systemSoundID)
}

#Preview {
    ContentView()
}
