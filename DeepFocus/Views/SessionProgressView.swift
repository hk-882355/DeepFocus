import SwiftUI

struct SessionProgressView: View {
    let currentSession: Int
    let totalSessions: Int
    let progress: Double
    let accentColor: Color

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("SESSION")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(hex: 0x6E6E73))
                    .tracking(2)

                Spacer()

                Text("\(currentSession) of \(totalSessions)")
                    .font(.system(size: 13, weight: .light, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.8))
            }

            HStack(spacing: 8) {
                ForEach(1...totalSessions, id: \.self) { session in
                    SessionDot(
                        isFilled: session < currentSession,
                        isCurrent: session == currentSession,
                        progress: session == currentSession ? fractionalProgress : 0,
                        accentColor: accentColor
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5)
                )
        )
    }

    private var fractionalProgress: Double {
        let completed = Double(currentSession - 1)
        let total = Double(totalSessions)
        guard total > 0 else { return 0 }
        let sessionFraction = (progress * total) - completed
        return max(0, min(1, sessionFraction))
    }
}

private struct SessionDot: View {
    let isFilled: Bool
    let isCurrent: Bool
    let progress: Double
    let accentColor: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.08))

                RoundedRectangle(cornerRadius: 3)
                    .fill(accentColor.opacity(isFilled ? 0.8 : 0.6))
                    .frame(width: geometry.size.width * fillAmount)
                    .animation(.easeInOut(duration: 0.4), value: fillAmount)
            }
        }
        .frame(height: 4)
    }

    private var fillAmount: Double {
        if isFilled { return 1.0 }
        if isCurrent { return progress }
        return 0
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SessionProgressView(
            currentSession: 2,
            totalSessions: 4,
            progress: 0.35,
            accentColor: Color(hex: 0xF5F0EB)
        )
        .padding()
    }
}
