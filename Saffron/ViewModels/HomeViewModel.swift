import Foundation
import Observation

@Observable
final class HomeViewModel {
    // CloudKit syncs automatically — there is nothing to trigger manually.
    // The pull-to-refresh gesture completes immediately after this returns.
    func refresh() async {}
}
