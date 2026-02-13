import UserNotifications

final class NotificationManager: @unchecked Sendable {
    static let shared = NotificationManager()

    private var hasRequested = false

    private init() {}

    func requestAuthorization() {
        guard !hasRequested else { return }
        hasRequested = true
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }

    func scheduleTimerNotification(after interval: TimeInterval, mode: TimerMode) {
        let content = UNMutableNotificationContent()
        content.title = "DeepFocus"

        switch mode {
        case .focus:
            content.body = "Focus session complete! Time for a break."
        case .shortBreak:
            content.body = "Break's over! Ready to focus again?"
        case .longBreak:
            content.body = "Long break done! Start a new cycle."
        }

        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(interval, 1),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "timer-completion",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleCompletionNotification(mode: TimerMode) {
        // Only schedule if app is in background
        // This is a fallback; primary notification is scheduled on background transition
    }

    func cancelPendingNotifications() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["timer-completion"])
    }
}
