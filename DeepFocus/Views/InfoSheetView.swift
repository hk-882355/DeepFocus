import SwiftUI

struct InfoSheetView: View {
    @Environment(\.dismiss) private var dismiss

    private let privacyURL = URL(string: "https://hk-882355.github.io/DeepFocus/privacy.html")!
    private let githubURL = URL(string: "https://github.com/hk-882355/DeepFocus")!

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 32)

                Text("DEEPFOCUS")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color(hex: 0xF5F0EB))
                    .tracking(6)

                Text("v1.0")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color(hex: 0x6E6E73))
                    .padding(.top, 4)

                Spacer().frame(height: 36)

                VStack(spacing: 0) {
                    infoRow(icon: "lock.shield", label: "Privacy Policy") {
                        UIApplication.shared.open(privacyURL)
                    }

                    Divider()
                        .background(Color.white.opacity(0.06))

                    infoRow(icon: "chevron.left.forwardslash.chevron.right", label: "Source Code") {
                        UIApplication.shared.open(githubURL)
                    }
                }
                .background(Color.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5)
                )
                .padding(.horizontal, 20)

                Spacer()

                Text("Made with focus")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color(hex: 0x6E6E73))
                    .tracking(2)

                Spacer().frame(height: 24)
            }
        }
    }

    private func infoRow(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(Color(hex: 0x6E6E73))
                    .frame(width: 24)

                Text(label)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color(hex: 0xF5F0EB).opacity(0.9))

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(hex: 0x6E6E73))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    InfoSheetView()
}
