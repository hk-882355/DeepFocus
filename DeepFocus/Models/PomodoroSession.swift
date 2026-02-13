import Foundation

struct PomodoroSession {
    var currentSession: Int = 1
    let totalSessions: Int = 4

    var progress: Double {
        Double(currentSession - 1) / Double(totalSessions)
    }

    var isLastSession: Bool {
        currentSession >= totalSessions
    }

    mutating func advance() {
        if currentSession < totalSessions {
            currentSession += 1
        } else {
            currentSession = 1
        }
    }

    mutating func reset() {
        currentSession = 1
    }
}
