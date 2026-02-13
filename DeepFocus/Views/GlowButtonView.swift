import SwiftUI

struct GlowButtonView: View {
    let isRunning: Bool
    let accentColor: Color
    let glowColor: Color
    let onTap: () -> Void
    let onLongPress: () -> Void

    @State private var isPressed = false

    private var label: String {
        isRunning ? "PAUSE" : "START"
    }

    private var icon: String {
        isRunning ? "pause.fill" : "play.fill"
    }

    var body: some View {
        VStack(spacing: 10) {
            Button {
                onTap()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                    Text(label)
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .tracking(4)
                }
                .foregroundStyle(.white.opacity(0.9))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 27)
                        .fill(Color.white.opacity(isPressed ? 0.08 : 0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: 27)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.15),
                                            .white.opacity(0.05)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 0.5
                                )
                        )
                )
                .shadow(color: glowColor.opacity(isPressed ? 0.15 : 0.08), radius: 20)
                .scaleEffect(isPressed ? 0.98 : 1.0)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 1.0)
                    .onEnded { _ in
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.impactOccurred()
                        onLongPress()
                    }
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPressed = false
                        }
                    }
            )
            .sensoryFeedback(.impact(weight: .light), trigger: isRunning)
            .animation(.easeInOut(duration: 0.4), value: isRunning)

            Text("long press to reset")
                .font(.system(size: 10, weight: .regular))
                .foregroundStyle(Color(hex: 0x3A3A3C))
                .tracking(1)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        GlowButtonView(
            isRunning: false,
            accentColor: Color(hex: 0xF5F0EB),
            glowColor: Color(hex: 0xD4C5A9),
            onTap: {},
            onLongPress: {}
        )
        .padding()
    }
}
