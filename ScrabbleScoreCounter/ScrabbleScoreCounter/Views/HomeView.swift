import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GameSession.createdAt, order: .reverse) private var games: [GameSession]
    @State private var path = NavigationPath()
    @State private var appear = false

    private var activeGames: [GameSession] {
        games.filter(\.isActive)
    }

    private var pastGames: [GameSession] {
        games.filter { !$0.isActive }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                BoardBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        header
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 16)

                        newGameButton
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 20)

                        if !activeGames.isEmpty {
                            section(title: "In Progress", games: activeGames, active: true)
                        }

                        section(title: "Past Games", games: pastGames, active: false)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .newGame:
                    NewGameView { session in
                        path.append(Route.activeGame(session.id))
                    }
                case .activeGame(let id):
                    if let session = games.first(where: { $0.id == id }) {
                        ActiveGameView(game: session) {
                            path = NavigationPath()
                        }
                    } else {
                        Text("Game not found")
                            .foregroundStyle(AppTheme.tileCream)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.55)) {
                appear = true
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Scrabble Score")
                .font(AppTheme.displayFont)
                .foregroundStyle(AppTheme.tileCream)
            Text("Keep turn totals for every game night.")
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.tileCream.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private var newGameButton: some View {
        Button {
            path.append(Route.newGame)
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("New Game")
                    .font(AppTheme.titleFont)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .opacity(0.7)
            }
            .foregroundStyle(AppTheme.ink)
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppTheme.tileCream)
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 6)
            )
        }
        .buttonStyle(TileButtonStyle())
    }

    @ViewBuilder
    private func section(title: String, games: [GameSession], active: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppTheme.titleFont)
                .foregroundStyle(AppTheme.tileCream)

            if games.isEmpty {
                Text(active ? "No games in progress." : "Finished games will show up here.")
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.tileCream.opacity(0.65))
                    .padding(.vertical, 8)
            } else {
                ForEach(games, id: \.id) { game in
                    Button {
                        path.append(Route.activeGame(game.id))
                    } label: {
                        GameRowView(game: game)
                    }
                    .buttonStyle(TileButtonStyle())
                    .contextMenu {
                        if !game.isActive {
                            Button("Delete", role: .destructive) {
                                modelContext.delete(game)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct GameRowView: View {
    let game: GameSession

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let date = game.endedAt ?? game.createdAt
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(game.displayTitle)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(1)
                Spacer()
                if game.isActive {
                    Text("Live")
                        .font(AppTheme.captionFont.weight(.semibold))
                        .foregroundStyle(AppTheme.accentCoral)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.accentCoral.opacity(0.15), in: Capsule())
                }
            }

            HStack(spacing: 12) {
                ForEach(game.sortedPlayers, id: \.id) { player in
                    VStack(spacing: 2) {
                        Text("\(player.totalScore)")
                            .font(.system(.title3, design: .rounded).weight(.bold))
                            .foregroundStyle(AppTheme.ink)
                        Text(player.name)
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.softInk)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            Text(dateText)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.softInk.opacity(0.8))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.creamWash.opacity(0.95))
        )
    }
}

enum Route: Hashable {
    case newGame
    case activeGame(UUID)
}

#Preview {
    HomeView()
        .modelContainer(for: [SavedPlayer.self, GameSession.self, PlayerScore.self, TurnEntry.self], inMemory: true)
}
