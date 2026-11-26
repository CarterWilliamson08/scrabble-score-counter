import SwiftUI
import SwiftData

struct NewGameView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \SavedPlayer.lastUsedAt, order: .reverse) private var savedPlayers: [SavedPlayer]

    var onStarted: (GameSession) -> Void

    @State private var playerCount = 2
    @State private var names: [String] = Array(repeating: "", count: 4)
    @State private var saveAsRecurring = true
    @State private var showValidation = false

    private var canStart: Bool {
        (0..<playerCount).allSatisfy { !names[$0].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    var body: some View {
        ZStack {
            BoardBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("New Game")
                        .font(AppTheme.displayFont)
                        .foregroundStyle(AppTheme.tileCream)

                    playerCountPicker

                    ForEach(0..<playerCount, id: \.self) { index in
                        playerField(index: index)
                    }

                    if !savedPlayers.isEmpty {
                        recurringSection
                    }

                    Toggle(isOn: $saveAsRecurring) {
                        Text("Save new names as recurring players")
                            .font(AppTheme.bodyFont)
                            .foregroundStyle(AppTheme.tileCream)
                    }
                    .tint(AppTheme.accentCoral)

                    if showValidation && !canStart {
                        Text("Enter a name for each player.")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(Color.orange.opacity(0.95))
                    }

                    Button(action: startGame) {
                        Text("Start Game")
                            .font(AppTheme.titleFont)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .foregroundStyle(AppTheme.ink)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(canStart ? AppTheme.tileCream : AppTheme.tileCream.opacity(0.45))
                            )
                    }
                    .buttonStyle(TileButtonStyle())
                    .disabled(!canStart && showValidation)
                    .padding(.top, 4)
                }
                .padding(20)
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
                    .foregroundStyle(AppTheme.tileCream)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var playerCountPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Players")
                .font(AppTheme.titleFont)
                .foregroundStyle(AppTheme.tileCream)

            HStack(spacing: 10) {
                ForEach(1...4, id: \.self) { count in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            playerCount = count
                        }
                    } label: {
                        Text("\(count)")
                            .font(.system(.title3, design: .rounded).weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .foregroundStyle(playerCount == count ? AppTheme.ink : AppTheme.tileCream)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(playerCount == count ? AppTheme.tileCream : Color.white.opacity(0.12))
                            )
                    }
                    .buttonStyle(TileButtonStyle())
                }
            }
        }
    }

    private func playerField(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Player \(index + 1)")
                .font(AppTheme.captionFont.weight(.semibold))
                .foregroundStyle(AppTheme.tileCream.opacity(0.8))

            TextField("Name", text: $names[index])
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppTheme.creamWash)
                )
                .foregroundStyle(AppTheme.ink)
        }
    }

    private var recurringSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recurring Players")
                .font(AppTheme.titleFont)
                .foregroundStyle(AppTheme.tileCream)

            FlowLayout(spacing: 8) {
                ForEach(savedPlayers, id: \.id) { player in
                    Button {
                        assignRecurring(player.name)
                    } label: {
                        Text(player.name)
                            .font(AppTheme.bodyFont.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundStyle(AppTheme.ink)
                            .background(AppTheme.tileCream.opacity(0.92), in: Capsule())
                    }
                    .buttonStyle(TileButtonStyle())
                    .contextMenu {
                        Button("Remove", role: .destructive) {
                            modelContext.delete(player)
                        }
                    }
                }
            }
        }
    }

    private func assignRecurring(_ name: String) {
        if let empty = (0..<playerCount).first(where: { names[$0].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            names[empty] = name
            return
        }
        // Replace last slot if all filled
        names[playerCount - 1] = name
    }

    private func startGame() {
        guard canStart else {
            showValidation = true
            return
        }

        let trimmed = (0..<playerCount).map {
            names[$0].trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if saveAsRecurring {
            for name in trimmed {
                if let existing = savedPlayers.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) {
                    existing.lastUsedAt = Date()
                } else {
                    modelContext.insert(SavedPlayer(name: name))
                }
            }
        }

        let session = GameSession(playerNames: trimmed)
        modelContext.insert(session)
        try? modelContext.save()
        onStarted(session)
    }
}

/// Simple wrapping layout for recurring player chips.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var width: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            width = max(width, x - spacing)
        }

        return (CGSize(width: width, height: y + rowHeight), frames)
    }
}

#Preview {
    NavigationStack {
        NewGameView(onStarted: { _ in })
    }
    .modelContainer(for: [SavedPlayer.self, GameSession.self, PlayerScore.self, TurnEntry.self], inMemory: true)
}
