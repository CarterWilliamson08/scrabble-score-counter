import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void

    @State private var tileScale: CGFloat = 0.4
    @State private var tileOpacity: Double = 0
    @State private var titleOffset: CGFloat = 24
    @State private var titleOpacity: Double = 0
    @State private var pulse = false

    var body: some View {
        ZStack {
            BoardBackground()

            VStack(spacing: 28) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.tileCream)
                        .frame(width: 112, height: 112)
                        .overlay {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(AppTheme.tileEdge, lineWidth: 3)
                        }
                        .shadow(color: .black.opacity(0.25), radius: 16, y: 10)
                        .scaleEffect(tileScale)
                        .opacity(tileOpacity)

                    Text("S")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)
                        .scaleEffect(tileScale)
                        .opacity(tileOpacity)
                }
                .scaleEffect(pulse ? 1.04 : 1.0)

                VStack(spacing: 8) {
                    Text("Scrabble Score")
                        .font(AppTheme.displayFont)
                        .foregroundStyle(AppTheme.tileCream)
                    Text("Turn totals, kept simple")
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.tileCream.opacity(0.8))
                }
                .offset(y: titleOffset)
                .opacity(titleOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.68)) {
                tileScale = 1
                tileOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                titleOffset = 0
                titleOpacity = 1
            }
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true).delay(0.45)) {
                pulse = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                onFinished()
            }
        }
    }
}

#Preview {
    SplashView(onFinished: {})
}
