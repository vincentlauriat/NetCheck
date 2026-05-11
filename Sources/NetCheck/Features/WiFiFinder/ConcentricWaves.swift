import SwiftUI

struct ConcentricWaves: View {
    let color: Color
    let duration: Double
    let strength: Double   // 0.0 (faible) → 1.0 (fort)
    @State private var animate = false

    // Propriétés visuelles interpolées selon la force du signal
    private var waveCount: Int    { 3 + Int(strength * 4) }           // 3 → 7
    private var lineWidth: Double { 0.8 + strength * 2.2 }            // 0.8px → 3px
    private var startOpacity: Double { 0.2 + strength * 0.55 }        // 0.20 → 0.75
    private var maxExpansion: Double { 0.5 + strength * 2.0 }         // 0.5 → 2.5 (rayon relatif)

    var body: some View {
        ZStack {
            ForEach(0..<waveCount, id: \.self) { i in
                let t = waveCount > 1 ? Double(i) / Double(waveCount - 1) : 0
                let targetScale = 1.0 + t * maxExpansion
                let opacity = startOpacity * (1.0 - t * 0.8)

                Circle()
                    .stroke(color.opacity(animate ? 0 : opacity), lineWidth: lineWidth)
                    .scaleEffect(animate ? targetScale : 0.15 + t * 0.1)
                    .animation(
                        .easeOut(duration: duration)
                        .repeatForever(autoreverses: false)
                        .delay(Double(i) * duration / Double(waveCount)),
                        value: animate
                    )
            }
        }
        .frame(width: 180, height: 180)
        .onAppear { animate = true }
        .onChange(of: duration) { restart() }
        .onChange(of: waveCount) { restart() }
    }

    private func restart() {
        animate = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { animate = true }
    }
}
