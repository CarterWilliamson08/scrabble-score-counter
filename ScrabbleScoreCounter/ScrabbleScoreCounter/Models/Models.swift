import Foundation
import SwiftData

@Model
final class SavedPlayer {
    var id: UUID
    var name: String
    var createdAt: Date
    var lastUsedAt: Date

    init(name: String) {
        self.id = UUID()
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.createdAt = Date()
        self.lastUsedAt = Date()
    }
}

@Model
final class GameSession {
    var id: UUID
    var createdAt: Date
    var endedAt: Date?
    var isActive: Bool
    @Relationship(deleteRule: .cascade, inverse: \PlayerScore.game)
    var players: [PlayerScore]
    @Relationship(deleteRule: .cascade, inverse: \TurnEntry.game)
    var turns: [TurnEntry]

    init(playerNames: [String]) {
        self.id = UUID()
        self.createdAt = Date()
        self.endedAt = nil
        self.isActive = true
        self.players = playerNames.enumerated().map { index, name in
            PlayerScore(name: name, order: index)
        }
        self.turns = []
    }

    var sortedPlayers: [PlayerScore] {
        players.sorted { $0.order < $1.order }
    }

    var winnerNames: [String] {
        let ranked = sortedPlayers
        guard let top = ranked.map(\.totalScore).max(), top > 0 else { return [] }
        return ranked.filter { $0.totalScore == top }.map(\.name)
    }

    var displayTitle: String {
        sortedPlayers.map(\.name).joined(separator: ", ")
    }
}

@Model
final class PlayerScore {
    var id: UUID
    var name: String
    var order: Int
    var game: GameSession?

    init(name: String, order: Int) {
        self.id = UUID()
        self.name = name
        self.order = order
    }

    var totalScore: Int {
        guard let game else { return 0 }
        return game.turns
            .filter { $0.playerID == id }
            .reduce(0) { $0 + $1.points }
    }
}

@Model
final class TurnEntry {
    var id: UUID
    var playerID: UUID
    var playerName: String
    var points: Int
    var createdAt: Date
    var game: GameSession?

    init(playerID: UUID, playerName: String, points: Int) {
        self.id = UUID()
        self.playerID = playerID
        self.playerName = playerName
        self.points = points
        self.createdAt = Date()
    }
}
