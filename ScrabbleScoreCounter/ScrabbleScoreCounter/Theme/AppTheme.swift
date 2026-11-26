import SwiftUI

enum AppTheme {
    static let boardGreen = Color(red: 0.12, green: 0.42, blue: 0.28)
    static let boardGreenDark = Color(red: 0.07, green: 0.28, blue: 0.18)
    static let tileCream = Color(red: 0.96, green: 0.91, blue: 0.78)
    static let tileEdge = Color(red: 0.78, green: 0.68, blue: 0.48)
    static let ink = Color(red: 0.16, green: 0.14, blue: 0.12)
    static let softInk = Color(red: 0.35, green: 0.32, blue: 0.28)
    static let accentCoral = Color(red: 0.86, green: 0.38, blue: 0.28)
    static let creamWash = Color(red: 0.98, green: 0.96, blue: 0.90)

    static let displayFont = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let titleFont = Font.system(.title2, design: .rounded).weight(.semibold)
    static let bodyFont = Font.system(.body, design: .rounded)
    static let captionFont = Font.system(.caption, design: .rounded)
}

struct BoardBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                AppTheme.boardGreen,
                AppTheme.boardGreenDark,
                Color(red: 0.05, green: 0.20, blue: 0.14)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay {
            GeometryReader { geo in
                Canvas { context, size in
                    let spacing: CGFloat = 28
                    var path = Path()
                    stride(from: 0.0, through: size.width, by: spacing).forEach { x in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    }
                    stride(from: 0.0, through: size.height, by: spacing).forEach { y in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }
                    context.stroke(path, with: .color(.white.opacity(0.05)), lineWidth: 1)
                }
            }
            .allowsHitTesting(false)
        }
    }
}

struct TileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.72), value: configuration.isPressed)
    }
}
