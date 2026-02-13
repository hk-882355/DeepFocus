import SwiftUI

struct TimerDisplayView: View {
    let displayTime: String
    let progress: Double
    let accentColor: Color
    let glowColor: Color
    let isRunning: Bool
    let transitionTrigger: Int
    let canAdjust: Bool
    let onAdjust: (Int) -> Void

    @State private var glowIntensity: Double = 0.5
    @State private var completionRingScale: CGFloat = 1.0
    @State private var completionRingOpacity: Double = 0
    @State private var innerFlashOpacity: Double = 0
    @State private var lastDragStep: Int = 0
    @State private var isDragging: Bool = false

    private let ringSize: CGFloat = 260
    private let ringLineWidth: CGFloat = 2.5

    var body: some View {
        ZStack {
            completionBurstRing
            progressRing
            timerText
        }
        .frame(width: ringSize + 40, height: ringSize + 40)
        .onChange(of: isRunning) { _, running in
            if running { startPulse() } else { stopPulse() }
        }
        .onChange(of: transitionTrigger) { _, _ in
            playTransitionAnimation()
        }
    }

    // MARK: - Completion burst ring (expands outward on transition)

    private var completionBurstRing: some View {
        ZStack {
            Circle()
                .strokeBorder(glowColor.opacity(completionRingOpacity), lineWidth: 1.5)
                .frame(width: ringSize, height: ringSize)
                .scaleEffect(completionRingScale)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            glowColor.opacity(innerFlashOpacity * 0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: ringSize / 2
                    )
                )
                .frame(width: ringSize, height: ringSize)
        }
    }

    // MARK: - Progress ring

    private var progressRing: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.white.opacity(0.06), lineWidth: ringLineWidth)
                .frame(width: ringSize, height: ringSize)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    accentColor,
                    style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .butt)
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .shadow(color: glowColor.opacity(glowIntensity * 0.6), radius: 8)
                .animation(.easeInOut(duration: 0.5), value: progress)

            if progress > 0.01 {
                Circle()
                    .fill(accentColor)
                    .frame(width: 5, height: 5)
                    .shadow(color: glowColor.opacity(0.8), radius: 6)
                    .offset(y: -ringSize / 2)
                    .rotationEffect(.degrees(360 * progress - 90))
                    .animation(.easeInOut(duration: 0.5), value: progress)
            }
        }
    }

    // MARK: - Timer text

    private var timerText: some View {
        Text(displayTime)
            .font(.system(size: 64, weight: .ultraLight, design: .monospaced))
            .foregroundStyle(.white)
            .tracking(4)
            .shadow(color: glowColor.opacity(glowIntensity * 0.6), radius: 12)
            .shadow(color: glowColor.opacity(glowIntensity * 0.3), radius: 30)
            .shadow(color: glowColor.opacity(glowIntensity * 0.1), radius: 60)
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.3), value: displayTime)
            .animation(.easeInOut(duration: 0.8), value: glowColor)
            .scaleEffect(isDragging ? 1.04 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isDragging)
            .gesture(durationAdjustGesture)
    }

    private var durationAdjustGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                guard canAdjust else { return }
                if !isDragging { isDragging = true }
                let currentStep = -Int(round(value.translation.height / 35))
                let delta = currentStep - lastDragStep
                if delta != 0 {
                    lastDragStep = currentStep
                    onAdjust(delta)
                }
            }
            .onEnded { _ in
                isDragging = false
                lastDragStep = 0
            }
    }

    // MARK: - Animations

    private func startPulse() {
        withAnimation(
            .easeInOut(duration: 2.5)
            .repeatForever(autoreverses: true)
        ) {
            glowIntensity = 1.0
        }
    }

    private func stopPulse() {
        withAnimation(.easeInOut(duration: 0.8)) {
            glowIntensity = 0.5
        }
    }

    private func playTransitionAnimation() {
        completionRingScale = 1.0
        completionRingOpacity = 0.8
        innerFlashOpacity = 1.0

        withAnimation(.easeOut(duration: 1.2)) {
            completionRingScale = 1.4
            completionRingOpacity = 0
        }

        withAnimation(.easeOut(duration: 0.6)) {
            innerFlashOpacity = 0
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        TimerDisplayView(
            displayTime: "25:00",
            progress: 0.3,
            accentColor: Color(hex: 0xF5F0EB),
            glowColor: Color(hex: 0xD4C5A9),
            isRunning: false,
            transitionTrigger: 0,
            canAdjust: true,
            onAdjust: { _ in }
        )
    }
}
