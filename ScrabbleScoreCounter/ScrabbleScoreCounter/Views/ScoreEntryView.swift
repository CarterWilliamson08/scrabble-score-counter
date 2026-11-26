import SwiftUI

struct ScoreEntryView: View {
    let playerName: String
    var onSubmit: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var digits = ""
    @FocusState private var focused: Bool

    private var points: Int? {
        Int(digits)
    }

    private var canSubmit: Bool {
        guard let points, points >= 0, points <= 999 else { return false }
        return !digits.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 6) {
                    Text(playerName)
                        .font(AppTheme.titleFont)
                        .foregroundStyle(AppTheme.ink)
                    Text("Turn total")
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.softInk)
                }
                .padding(.top, 8)

                TextField("0", text: $digits)
                    .keyboardType(.numberPad)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .focused($focused)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppTheme.creamWash)
                    )
                    .padding(.horizontal, 24)

                Text("Enter the points scored this turn (not tile values).")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.softInk)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                Spacer()

                Button {
                    guard let points, canSubmit else { return }
                    onSubmit(points)
                    dismiss()
                } label: {
                    Text("Add Score")
                        .font(AppTheme.titleFont)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundStyle(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(canSubmit ? AppTheme.boardGreen : AppTheme.boardGreen.opacity(0.4))
                        )
                }
                .disabled(!canSubmit)
                .buttonStyle(TileButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("Enter Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                focused = true
            }
        }
    }
}

#Preview {
    ScoreEntryView(playerName: "Alex", onSubmit: { _ in })
}
