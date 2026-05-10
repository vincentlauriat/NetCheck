import SwiftUI

public struct OrganicBubble: View {
    let size: CGFloat
    let color: Color
    let offset: CGPoint
    @State private var phase: Double = 0

    public init(size: CGFloat, color: Color, offset: CGPoint) {
        self.size = size; self.color = color; self.offset = offset
    }

    public var body: some View {
        Ellipse()
            .fill(color.opacity(0.25))
            .frame(width: size * (1 + 0.05 * sin(phase)),
                   height: size * 0.92 * (1 + 0.04 * cos(phase * 1.3)))
            .offset(x: offset.x + 3 * sin(phase * 0.7),
                    y: offset.y + 4 * cos(phase * 0.5))
            .blur(radius: 1)
            .onAppear {
                withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                    phase = .pi * 2
                }
            }
    }
}
