import SwiftUI
import SwiftData

@main
struct ScrabbleScoreCounterApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SavedPlayer.self,
            GameSession.self,
            PlayerScore.self,
            TurnEntry.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
