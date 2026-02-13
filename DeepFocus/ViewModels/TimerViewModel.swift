import Foundation
import Observation
import UIKit

@Observable
final class TimerViewModel {
    var activeMode: TimerMode = .focus
    var displayedMode: TimerMode = .focus
    var timeRemaining: TimeInterval
    var isRunning: Bool = false
    var session: PomodoroSession = PomodoroSession()
    var transitionTrigger: Int = 0

    // Custom durations (backed by UserDefaults for persistence)
    private(set) var focusDuration: TimeInterval
    private(set) var restDuration: TimeInterval
    private(set) var longRestDuration: TimeInterval

    private var timer: Timer?
    private var backgroundDate: Date?

    var isViewingActiveMode: Bool {
        displayedMode == activeMode
    }

    var displayTime: String {
        let time = isViewingActiveMode ? timeRemaining : duration(for: displayedMode)
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var progressFraction: Double {
        guard isViewingActiveMode else { return 0 }
        let total = duration(for: activeMode)
        guard total > 0 else { return 0 }
        return 1.0 - (timeRemaining / total)
    }

    var sessionProgressFraction: Double {
        let completedSessions = Double(session.currentSession - 1)
        let currentProgress = activeMode == .focus ? activeFocusProgress : 0
        return (completedSessions + currentProgress) / Double(session.totalSessions)
    }

    var canAdjustDuration: Bool {
        !(isRunning && isViewingActiveMode)
    }

    private var activeFocusProgress: Double {
        let total = duration(for: .focus)
        guard total > 0 else { return 0 }
        return 1.0 - (timeRemaining / total)
    }

    func duration(for mode: TimerMode) -> TimeInterval {
        switch mode {
        case .focus: focusDuration
        case .shortBreak: restDuration
        case .longBreak: longRestDuration
        }
    }

    init() {
        focusDuration = Self.loadDuration(for: .focus)
        restDuration = Self.loadDuration(for: .shortBreak)
        longRestDuration = Self.loadDuration(for: .longBreak)
        timeRemaining = Self.loadDuration(for: .focus)
        observeAppLifecycle()
    }

    // MARK: - Duration Adjustment

    func adjustDuration(steps: Int) {
        let mode = displayedMode
        let step = mode.durationStep
        var newDuration = duration(for: mode) + TimeInterval(steps) * step
        newDuration = min(max(newDuration, mode.minDuration), mode.maxDuration)
        guard newDuration != duration(for: mode) else { return }

        setDuration(newDuration, for: mode)

        if isViewingActiveMode {
            timeRemaining = newDuration
        }

        UISelectionFeedbackGenerator().selectionChanged()
    }

    // MARK: - User Actions

    func switchTab(_ newMode: TimerMode) {
        displayedMode = newMode
    }

    func toggleStartPause() {
        if isViewingActiveMode && isRunning {
            pause()
        } else if isViewingActiveMode && !isRunning {
            start()
        } else {
            stopTimer()
            activeMode = displayedMode
            timeRemaining = duration(for: displayedMode)
            start()
        }
    }

    func reset() {
        stopTimer()
        activeMode = displayedMode
        timeRemaining = duration(for: displayedMode)
    }

    // MARK: - Timer Engine

    private func start() {
        guard !isRunning else { return }
        NotificationManager.shared.requestAuthorization()
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard timeRemaining > 0 else { return }
        timeRemaining -= 1

        if timeRemaining <= 0 {
            timerCompleted()
        }
    }

    // MARK: - Auto-Cycle

    private func timerCompleted() {
        stopTimer()
        playCompletionFeedback()
        transitionTrigger += 1

        let nextMode: TimerMode
        switch activeMode {
        case .focus:
            if session.isLastSession {
                session.advance()
                nextMode = .longBreak
            } else {
                session.advance()
                nextMode = .shortBreak
            }
        case .shortBreak, .longBreak:
            nextMode = .focus
        }

        NotificationManager.shared.scheduleCompletionNotification(mode: activeMode)

        activeMode = nextMode
        displayedMode = nextMode
        timeRemaining = duration(for: nextMode)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.start()
        }
    }

    private func playCompletionFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        SoundPlayer.playCompletion()
    }

    // MARK: - Duration Persistence

    private func setDuration(_ value: TimeInterval, for mode: TimerMode) {
        switch mode {
        case .focus: focusDuration = value
        case .shortBreak: restDuration = value
        case .longBreak: longRestDuration = value
        }
        Self.saveDuration(value, for: mode)
    }

    private static func loadDuration(for mode: TimerMode) -> TimeInterval {
        let key = "duration_\(mode.id)"
        let saved = UserDefaults.standard.double(forKey: key)
        return saved > 0 ? saved : mode.factoryDuration
    }

    private static func saveDuration(_ value: TimeInterval, for mode: TimerMode) {
        let key = "duration_\(mode.id)"
        UserDefaults.standard.set(value, forKey: key)
    }

    // MARK: - Background Support

    private func observeAppLifecycle() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleBackgroundTransition()
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleForegroundTransition()
        }
    }

    private func handleBackgroundTransition() {
        guard isRunning else { return }
        backgroundDate = Date()
        NotificationManager.shared.scheduleTimerNotification(
            after: timeRemaining,
            mode: activeMode
        )
    }

    private func handleForegroundTransition() {
        guard let backgroundDate, isRunning else {
            self.backgroundDate = nil
            return
        }

        let elapsed = Date().timeIntervalSince(backgroundDate)
        self.backgroundDate = nil
        NotificationManager.shared.cancelPendingNotifications()

        if elapsed >= timeRemaining {
            timeRemaining = 0
            timerCompleted()
        } else {
            timeRemaining -= elapsed
        }
    }
}
