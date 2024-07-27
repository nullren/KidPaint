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
    
    @State private var paths: [DrawingPath] = []
    @State private var currentPath = DrawingPath()
    
    var body: some View {
        Canvas { context, size in
            for path in paths {
                drawPath(path, context: context)
            }
            drawPath(currentPath, context: context)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    currentPath.color = selectedColor
                    currentPath.points.append(value.location)
                }
                .onEnded { _ in
                    currentPath.color = selectedColor
                    paths.append(currentPath)
                    currentPath = DrawingPath()
                }
        )
    }
    
    private func drawPath(_ path: DrawingPath, context: GraphicsContext) {
        var drawingPath = Path()
        let width: Double = 40
        if let firstPoint = path.points.first {
            drawingPath.move(to: firstPoint)
            for point in path.points.dropFirst() {
                drawingPath.addLine(to: point)
            }
            // Draw start and end circles
            context.fill(Path(ellipseIn: CGRect(x: firstPoint.x - width/2, y: firstPoint.y - width/2, width: width, height: width)), with: .color(path.color))
            if let lastPoint = path.points.last {
                context.fill(Path(ellipseIn: CGRect(x: lastPoint.x - width/2, y: lastPoint.y - width/2, width: width, height: width)), with: .color(path.color))
            }
        }
        context.stroke(drawingPath, with: .color(path.color), lineWidth: width)
    }
}

func playBubblePopSound() {
    let systemSoundID: SystemSoundID = 1104 // Bubble pop sound
    AudioServicesPlaySystemSound(systemSoundID)
}

#Preview {
    ContentView()
}
