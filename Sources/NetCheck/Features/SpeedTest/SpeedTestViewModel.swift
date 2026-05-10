import SwiftUI
import NetCheckCore

@MainActor
@Observable
final class SpeedTestViewModel {
    private(set) var download: Double = 0
    private(set) var upload: Double = 0
    private(set) var rpm: Int = 0
    private(set) var isRunning = false
    private(set) var isDone = false

    private let service = SpeedTestService()
    private var testTask: Task<Void, Never>?

    func start() {
        guard !isRunning else { return }
        isRunning = true; isDone = false
        download = 0; upload = 0; rpm = 0
        testTask = Task {
            for await progress in await service.run() {
                download = progress.downloadMbps
                upload   = progress.uploadMbps
                rpm      = progress.rpm
                if progress.isComplete { isDone = true; isRunning = false }
            }
            isRunning = false
        }
    }

    var rpmLabel: String {
        switch rpm {
        case 0:       return "—"
        case ..<400:  return "Moyen"
        case ..<1000: return "Bon"
        default:      return "Excellent"
        }
    }
}
