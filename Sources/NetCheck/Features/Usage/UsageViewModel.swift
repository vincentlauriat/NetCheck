import SwiftUI
import NetCheckCore

@MainActor
@Observable
final class UsageViewModel {
    private(set) var results: [UsageResult] = []
    private(set) var isLoading = false
    private let service = UsageQualityService()

    func refresh() {
        results = []
        isLoading = true
        Task {
            for await result in service.stream() {
                withAnimation(.spring(duration: 0.45)) {
                    results.append(result)
                }
            }
            isLoading = false
        }
    }
}
