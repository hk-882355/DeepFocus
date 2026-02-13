import AVFoundation

enum SoundPlayer {
    private static var player: AVAudioPlayer?

    static func playCompletion() {
        guard let url = Bundle.main.url(
            forResource: "completion",
            withExtension: "caf"
        ) else {
            playSystemSound()
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            playSystemSound()
        }
    }

    private static func playSystemSound() {
        AudioServicesPlaySystemSound(1007) // tri-tone
    }
}
