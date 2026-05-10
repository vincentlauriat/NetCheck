import SwiftUI
import NetCheckCore

@MainActor
@Observable
final class UsageViewModel {
    private(set) var results: [UsageResult] = []
    private(set) var isLoading = false
    private let service = UsageQualityService()

    func refresh() {
        isLoading = true
        Task {
            results = await service.evaluate()
            isLoading = false
        }
    }
}
