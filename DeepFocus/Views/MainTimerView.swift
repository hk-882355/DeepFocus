import SwiftUI

struct MainTimerView: View {
    @State private var viewModel = TimerViewModel()

    var body: some View {
        ZStack {
            backgroundLayer
            contentLayer
        }
        .preferredColorScheme(.dark)
    }

    private var backgroundLayer: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            RadialGradient(
                colors: [
                    viewModel.displayedMode.glowColor.opacity(0.06),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.0), value: viewModel.displayedMode)
        }
    }

    private var contentLayer: some View {
        VStack(spacing: 0) {
            headerSection
            Spacer()
            TimerDisplayView(
                displayTime: viewModel.displayTime,
                progress: viewModel.progressFraction,
                accentColor: viewModel.displayedMode.accentColor,
                glowColor: viewModel.displayedMode.glowColor,
                isRunning: viewModel.isRunning && viewModel.isViewingActiveMode,
                transitionTrigger: viewModel.transitionTrigger,
                canAdjust: viewModel.canAdjustDuration,
                onAdjust: { viewModel.adjustDuration(steps: $0) }
            )
            Spacer().frame(height: 36)
            ModeChipsView(
                selectedMode: viewModel.displayedMode,
                activeMode: viewModel.activeMode,
                isRunning: viewModel.isRunning,
                onSelect: { viewModel.switchTab($0) }
            )
            Spacer().frame(height: 28)
            SessionProgressView(
                currentSession: viewModel.session.currentSession,
                totalSessions: viewModel.session.totalSessions,
                progress: viewModel.sessionProgressFraction,
                accentColor: viewModel.displayedMode.accentColor
            )
            Spacer()
            GlowButtonView(
                isRunning: viewModel.isRunning && viewModel.isViewingActiveMode,
                accentColor: viewModel.displayedMode.accentColor,
                glowColor: viewModel.displayedMode.glowColor,
                onTap: { viewModel.toggleStartPause() },
                onLongPress: { viewModel.reset() }
            )
            Spacer().frame(height: 50)
        }
        .padding(.horizontal, 28)
    }

    private var headerSection: some View {
        VStack(spacing: 6) {
            Text("DEEPFOCUS")
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundStyle(Color(hex: 0xF5F0EB).opacity(0.9))
                .tracking(6)

            Text("stay in the zone")
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundStyle(Color(hex: 0x6E6E73))
                .tracking(3)
        }
        .padding(.top, 16)
    }
}

#Preview {
    MainTimerView()
}
