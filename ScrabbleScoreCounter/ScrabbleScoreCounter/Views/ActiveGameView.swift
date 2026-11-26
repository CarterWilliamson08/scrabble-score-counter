import SwiftUI
import SwiftData

struct ActiveGameView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var game: GameSession
    var onEnded: () -> Void

    @State private var selectedPlayer: PlayerScore?
    @State private var showEndConfirm = false
    @State private var scoreBumpPlayerID: UUID?
    @State private var appear = false

    private var sortedTurns: [TurnEntry] {
        game.turns.sorted { $0.createdAt > $1.createdAt }
    }

    private var canUndo: Bool {
        game.isActive && !game.turns.isEmpty
    }

    var body: some View {
        ZStack {
            BoardBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    totalsGrid
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 12)

                    if game.isActive {
                        actionRow
                    } else {
                        finishedBanner
                    }

                    recentTurns
                }
                .padding(20)
                .padding(.bottom, 36)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(game.isActive ? "Active Game" : "Game Summary")
                    .font(AppTheme.bodyFont.weight(.semibold))
                    .foregroundStyle(AppTheme.tileCream)
            }
        }
        .sheet(item: $selectedPlayer) { player in
            ScoreEntryView(playerName: player.name) { points in
                addTurn(for: player, points: points)
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .confirmationDialog("End and save this game?", isPresented: $showEndConfirm, titleVisibility: .visible) {
            Button("End Game", role: .destructive, action: endGame)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Scores are saved to Past Games on the home screen.")
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.45)) {
                appear = true
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(game.displayTitle)
                .font(AppTheme.titleFont)
                .foregroundStyle(AppTheme.tileCream)
            Text(game.isActive ? "Tap a player to enter their turn total." : endedSubtitle)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.tileCream.opacity(0.75))
        }
    }

    private var endedSubtitle: String {
        let winners = game.winnerNames
        if winners.isEmpty {
            return "No points were recorded."
        }
        if winners.count == 1 {
            return "Winner: \(winners[0])"
        }
        return "Tie: \(winners.joined(separator: ", "))"
    }

    private var totalsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(game.sortedPlayers, id: \.id) { player in
                Button {
                    guard game.isActive else { return }
                    selectedPlayer = player
                } label: {
                    VStack(spacing: 8) {
                        Text(player.name)
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(AppTheme.ink)
                            .lineLimit(1)
                        Text("\(player.totalScore)")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.ink)
                            .contentTransition(.numericText())
                            .scaleEffect(scoreBumpPlayerID == player.id ? 1.08 : 1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 22)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(AppTheme.tileCream)
                            .shadow(color: .black.opacity(0.18), radius: 8, y: 5)
                    )
                    .overlay(alignment: .topTrailing) {
                        if game.isActive {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(AppTheme.accentCoral)
                                .padding(10)
                        }
                    }
                }
                .buttonStyle(TileButtonStyle())
                .disabled(!game.isActive)
            }
        }
    }

    private var actionRow: some View {
        HStack(spacing: 12) {
            Button(action: undoLastTurn) {
                Label("Undo", systemImage: "arrow.uturn.backward")
                    .font(AppTheme.bodyFont.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(canUndo ? AppTheme.tileCream : AppTheme.tileCream.opacity(0.4))
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(AppTheme.tileCream.opacity(canUndo ? 0.55 : 0.25), lineWidth: 1.5)
                    )
            }
            .disabled(!canUndo)
            .buttonStyle(TileButtonStyle())

            Button {
                showEndConfirm = true
            } label: {
                Label("End Game", systemImage: "flag.checkered")
                    .font(AppTheme.bodyFont.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(AppTheme.ink)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppTheme.accentCoral)
                    )
            }
            .buttonStyle(TileButtonStyle())
        }
    }

    private var finishedBanner: some View {
        HStack {
            Image(systemName: "checkmark.seal.fill")
            Text("Saved to history")
                .font(AppTheme.bodyFont.weight(.semibold))
            Spacer()
            Button("Home") { onEnded() }
                .font(AppTheme.bodyFont.weight(.semibold))
        }
        .foregroundStyle(AppTheme.ink)
        .padding(14)
        .background(AppTheme.tileCream.opacity(0.95), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var recentTurns: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Turns")
                .font(AppTheme.titleFont)
                .foregroundStyle(AppTheme.tileCream)

            if sortedTurns.isEmpty {
                Text("No turns yet.")
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.tileCream.opacity(0.65))
            } else {
                ForEach(sortedTurns.prefix(12), id: \.id) { turn in
                    HStack {
                        Text(turn.playerName)
                            .font(AppTheme.bodyFont.weight(.medium))
                            .foregroundStyle(AppTheme.ink)
                        Spacer()
                        Text("+\(turn.points)")
                            .font(.system(.body, design: .rounded).weight(.bold))
                            .foregroundStyle(AppTheme.accentCoral)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppTheme.creamWash.opacity(0.92))
                    )
                }
            }
        }
    }

    private func addTurn(for player: PlayerScore, points: Int) {
        let entry = TurnEntry(playerID: player.id, playerName: player.name, points: points)
        entry.game = game
        game.turns.append(entry)
        modelContext.insert(entry)
        try? modelContext.save()

        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
            scoreBumpPlayerID = player.id
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.easeOut(duration: 0.2)) {
                scoreBumpPlayerID = nil
            }
        }
    }

    private func undoLastTurn() {
        guard let last = sortedTurns.first else { return }
        game.turns.removeAll { $0.id == last.id }
        modelContext.delete(last)
        try? modelContext.save()
    }

    private func endGame() {
        game.isActive = false
        game.endedAt = Date()
        try? modelContext.save()
        onEnded()
    }
}

extension PlayerScore: Identifiable {}

#Preview {
    let session = GameSession(playerNames: ["Alex", "Sam"])
    return NavigationStack {
        ActiveGameView(game: session, onEnded: {})
    }
    .modelContainer(for: [SavedPlayer.self, GameSession.self, PlayerScore.self, TurnEntry.self], inMemory: true)
}
