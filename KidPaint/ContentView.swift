//
//  ContentView.swift
//  KidPaint
//
//  Created by Renning Bruns on 7/27/24.
//

import SwiftUI
import AVFoundation


struct ContentView: View {
    @State private var selectedColor: Color = .blue
    @State private var points: [CGPoint] = []
    @State private var colorPickerOffset: CGSize = .zero
    @State private var lastColorPickerOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                DrawingView(points: $points, selectedColor: selectedColor)
                    .background(Color.white)
                    .edgesIgnoringSafeArea(.all)
                
                ColorPicker(selectedColor: $selectedColor)
                    .padding()
                    .frame(width: 200, height: 200)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .offset(x: colorPickerOffset.width, y: colorPickerOffset.height)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                colorPickerOffset = CGSize(
                                    width: lastColorPickerOffset.width + value.translation.width,
                                    height: lastColorPickerOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                lastColorPickerOffset = colorPickerOffset
                            }
                    )
            }
        }
    }
}

struct ColorPicker: View {
    @Binding var selectedColor: Color
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple]
    let radius: CGFloat = 60 // Radius of the circular color picker

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(colors.enumerated()), id: \.element) { index, color in
                    Circle()
                        .fill(color)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: selectedColor == color ? 4 : 0)
                        )
                        .position(circularPosition(for: index, in: geometry.size))
                        .onTapGesture {
                            playBubblePopSound()
                            selectedColor = color
                            print("color changed to \(selectedColor)")
                        }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    private func circularPosition(for index: Int, in size: CGSize) -> CGPoint {
        let angle = (Double(index) / Double(colors.count)) * 2 * Double.pi
        let centerX = size.width / 2
        let centerY = size.height / 2
        let x = centerX + radius * CGFloat(cos(angle))
        let y = centerY + radius * CGFloat(sin(angle))
        return CGPoint(x: x, y: y)
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
