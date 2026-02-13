import SwiftUI

struct ModeChipsView: View {
    let selectedMode: TimerMode
    let activeMode: TimerMode
    let isRunning: Bool
    let onSelect: (TimerMode) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(TimerMode.allCases) { mode in
                ModeChip(
                    title: mode.chipLabel,
                    isSelected: mode == selectedMode,
                    hasRunningIndicator: mode == activeMode && isRunning && mode != selectedMode,
                    accentColor: mode.accentColor,
                    glowColor: mode.glowColor,
                    onTap: { onSelect(mode) }
                )
            }
        }
    }
}

private struct ModeChip: View {
    let title: String
    let isSelected: Bool
    let hasRunningIndicator: Bool
    let accentColor: Color
    let glowColor: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                if hasRunningIndicator {
                    PulsingDot(color: accentColor)
                }
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .tracking(1.5)
                    .foregroundStyle(
                        isSelected ? Color.black.opacity(0.85) : Color(hex: 0x6E6E73)
                    )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background {
                if isSelected {
                    Capsule()
                        .fill(accentColor.opacity(0.85))
                        .shadow(color: glowColor.opacity(0.5), radius: 10, y: 2)
                        .shadow(color: glowColor.opacity(0.25), radius: 20)
                        .shadow(color: glowColor.opacity(0.1), radius: 40)
                } else {
                    Capsule()
                        .fill(Color.white.opacity(0.04))
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
                        )
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.4), value: isSelected)
        .animation(.easeInOut(duration: 0.3), value: hasRunningIndicator)
    }
}

private struct PulsingDot: View {
    let color: Color
    @State private var isPulsing = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 5, height: 5)
            .opacity(isPulsing ? 0.4 : 1.0)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ModeChipsView(
            selectedMode: .shortBreak,
            activeMode: .focus,
            isRunning: true,
            onSelect: { _ in }
        )
    }
}
