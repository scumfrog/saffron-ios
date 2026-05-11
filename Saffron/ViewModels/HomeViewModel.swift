import Foundation
import Observation

@Observable
final class HomeViewModel {
    var isRefreshing = false

    /// Hook for manual refresh (CloudKit syncs automatically; this simulates a delay).
    func refresh() async {
        isRefreshing = true
        try? await Task.sleep(for: .milliseconds(600))
        isRefreshing = false
    }
}
