import SwiftUI

struct ConcentricWaves: View {
    let color: Color
    let duration: Double
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .stroke(color.opacity(animate ? 0 : 0.6 - Double(i) * 0.1), lineWidth: 1.5)
                    .scaleEffect(animate ? 1.0 + Double(i) * 0.3 : 0.3 + Double(i) * 0.05)
                    .animation(
                        .easeOut(duration: duration)
                        .repeatForever(autoreverses: false)
                        .delay(Double(i) * duration / 5),
                        value: animate
                    )
            }
        }
        .frame(width: 180, height: 180)
        .onAppear { animate = true }
        .onChange(of: duration) {
            animate = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { animate = true }
        }
    }
}
