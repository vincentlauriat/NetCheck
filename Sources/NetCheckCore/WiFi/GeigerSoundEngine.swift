import Foundation
import AVFoundation

public final class GeigerSoundEngine: @unchecked Sendable {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var tickTask: Task<Void, Never>?
    private var isRunning = false

    public init() {
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: nil)
        try? engine.start()
    }

    public func setSignal(_ signal: WiFiSignal) {
        let intervalMs = 80 + Int((1 - signal.strength) * 1920)
        restartTicking(intervalMs: intervalMs)
    }

    public func stop() {
        tickTask?.cancel()
        tickTask = nil
        isRunning = false
    }

    private func restartTicking(intervalMs: Int) {
        tickTask?.cancel()
        isRunning = true
        tickTask = Task { [weak self] in
            while !Task.isCancelled, self?.isRunning == true {
                self?.playTick()
                try? await Task.sleep(for: .milliseconds(intervalMs))
            }
        }
    }

    private func playTick() {
        let sampleRate = 44100.0
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCount = AVAudioFrameCount(sampleRate * 0.003)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        let channelData = buffer.floatChannelData![0]
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            channelData[i] = Float(0.6 * exp(-t * 800) * sin(2 * .pi * 1200 * t))
        }
        playerNode.play()
        playerNode.scheduleBuffer(buffer, completionHandler: nil)
    }
}
