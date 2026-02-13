import SwiftUI

enum TimerMode: String, CaseIterable, Identifiable {
    case focus = "FOCUS"
    case shortBreak = "REST"
    case longBreak = "LONG REST"

    var id: String { rawValue }

    var factoryDuration: TimeInterval {
        switch self {
        case .focus: 25 * 60
        case .shortBreak: 5 * 60
        case .longBreak: 15 * 60
        }
    }

    var minDuration: TimeInterval { 5 * 60 }

    var maxDuration: TimeInterval {
        switch self {
        case .focus: 120 * 60
        case .shortBreak: 30 * 60
        case .longBreak: 60 * 60
        }
    }

    var durationStep: TimeInterval { 5 * 60 }

    var chipLabel: String { rawValue }

    var displayName: String { rawValue }

    var accentColor: Color {
        switch self {
        case .focus: Color(hex: 0xF5F0EB)
        case .shortBreak: Color(hex: 0x7EB8E0)
        case .longBreak: Color(hex: 0x6A8FD4)
        }
    }

    var glowColor: Color {
        switch self {
        case .focus: Color(hex: 0xD4C5A9)
        case .shortBreak: Color(hex: 0x5E9EFF)
        case .longBreak: Color(hex: 0x3D6BB5)
        }
    }
}

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
