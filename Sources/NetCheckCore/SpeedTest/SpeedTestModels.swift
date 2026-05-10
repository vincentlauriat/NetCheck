import Foundation

public struct SpeedTestProgress: Sendable {
    public let downloadMbps: Double
    public let uploadMbps: Double
    public let rpm: Int
    public let isComplete: Bool

    public init(downloadMbps: Double, uploadMbps: Double, rpm: Int, isComplete: Bool) {
        self.downloadMbps = downloadMbps
        self.uploadMbps = uploadMbps
        self.rpm = rpm
        self.isComplete = isComplete
    }
}
