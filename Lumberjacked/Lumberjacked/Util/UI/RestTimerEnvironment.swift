//
//  RestTimerEnvironment.swift
//  Lumberjacked
//

import AudioToolbox
import AVFoundation
import Combine
import SwiftUI
import UserNotifications

private let notificationId = "lumberjacked-rest-timer"

// Kill-switch: set to false to revert to notification-only behavior if needed.
private let backgroundAudioEnabled = true

enum TimerSound: String, CaseIterable {
    case drum = "drum.wav"
    case glassDing = "glassding.wav"
    case metalDing = "metalding.wav"
    case metallaphone = "metallaphone.wav"
    case musicalDing = "musicalding.wav"
    case cinematicDing = "cinematicding.wav"
    case twoTone = "twotone.wav"
    case xylophone = "xylophone.wav"
    case microwave = "microwave.caf"
    case none = "none"

    var displayName: String {
        switch self {
        case .none: return "None"
        case .microwave: return "Microwave"
        case .cinematicDing: return "Cinematic Ding"
        case .drum: return "Drum"
        case .glassDing: return "Glass Ding"
        case .metalDing: return "Metal Ding"
        case .metallaphone: return "Metallaphone"
        case .musicalDing: return "Musical Ding"
        case .twoTone: return "Two Tone"
        case .xylophone: return "Xylophone"
        }
    }

    var fileName: String { String(rawValue.split(separator: ".").first ?? "") }
    var fileExtension: String { String(rawValue.split(separator: ".").last ?? "") }

    @discardableResult
    func play() -> AVAudioPlayer? {
        guard self != .none,
              let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension),
              let player = try? AVAudioPlayer(contentsOf: url) else { return nil }
        let headphonePorts: [AVAudioSession.Port] = [.headphones, .bluetoothA2DP, .bluetoothHFP, .bluetoothLE]
        let hasHeadphones = AVAudioSession.sharedInstance().currentRoute.outputs
            .contains { headphonePorts.contains($0.portType) }
        if hasHeadphones {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try? AVAudioSession.sharedInstance().setActive(true)
        }
        player.play()
        return player
    }
}

@Observable
class RestTimerEnvironment {
    var activeSetId: UUID? = nil
    var timeRemaining: Int = 0
    var totalTime: Int = 0
    var isRunning: Bool = false
    var showingZero: Bool = false
    var showTimerAlert: Bool = false

    private var timerCancellable: AnyCancellable?
    private var audioPlayer: AVAudioPlayer?
    private var silentLoopPlayer: AVAudioPlayer?
    // Absolute wall-clock expiry time — keeps the countdown accurate across
    // backgrounding, sleep, or any gap in Timer delivery.
    private var endDate: Date?
    private var isInForeground = true
    private var lifecycleObservers: [NSObjectProtocol] = []

    init() {
        // Using raw Obj-C notification names avoids a UIKit import.
        let active = NotificationCenter.default.addObserver(
            forName: Notification.Name("UIApplicationDidBecomeActiveNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isInForeground = true
            self?.syncToWallClock()
        }
        let background = NotificationCenter.default.addObserver(
            forName: Notification.Name("UIApplicationDidEnterBackgroundNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isInForeground = false
        }
        lifecycleObservers = [active, background]
    }

    deinit {
        lifecycleObservers.forEach { NotificationCenter.default.removeObserver($0) }
    }

    func start(seconds: Int, setId: UUID) {
        timerCancellable?.cancel()
        activeSetId = setId
        totalTime = seconds
        timeRemaining = seconds
        isRunning = true
        showingZero = false
        showTimerAlert = false
        let end = Date().addingTimeInterval(TimeInterval(seconds))
        endDate = end

        if backgroundAudioEnabled { startSilentLoop() }
        scheduleNotification(at: end)

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let end = self.endDate else { return }
                let remaining = Int(end.timeIntervalSinceNow.rounded(.up))
                if remaining > 0 {
                    self.timeRemaining = remaining
                } else if self.isInForeground || backgroundAudioEnabled {
                    self.handleExpiry(playSound: true)
                }
            }
    }

    func cancel() {
        timerCancellable?.cancel()
        isRunning = false
        showingZero = false
        activeSetId = nil
        timeRemaining = 0
        totalTime = 0
        endDate = nil
        if backgroundAudioEnabled { stopSilentLoop() }
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationId])
    }

    private func startSilentLoop() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
        guard let url = Bundle.main.url(forResource: "silent", withExtension: "wav") else { return }
        silentLoopPlayer = try? AVAudioPlayer(contentsOf: url)
        silentLoopPlayer?.numberOfLoops = -1
        silentLoopPlayer?.volume = 0
        silentLoopPlayer?.play()
    }

    private func stopSilentLoop() {
        silentLoopPlayer?.stop()
        silentLoopPlayer = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        try? AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default)
    }

    private func syncToWallClock() {
        guard isRunning, let end = endDate else { return }
        let remaining = Int(end.timeIntervalSinceNow.rounded(.up))
        if remaining <= 0 {
            handleExpiry(playSound: false)
        } else {
            timeRemaining = remaining
        }
    }

    private func handleExpiry(playSound: Bool) {
        timeRemaining = 0
        isRunning = false
        activeSetId = nil
        timerCancellable?.cancel()
        endDate = nil
        if backgroundAudioEnabled { stopSilentLoop() }
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationId])
        UNUserNotificationCenter.current()
            .removeDeliveredNotifications(withIdentifiers: [notificationId])
        if !isInForeground { showBackgroundBanner() }
        if playSound { playTimerSound() }
        showTimerAlert = true
        showingZero = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.showingZero = false
        }
    }

    private func showBackgroundBanner() {
        let content = UNMutableNotificationContent()
        content.title = "Rest complete"
        content.body = "Time to get back to work."
        content.sound = nil
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func playTimerSound() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        let soundRaw = UserDefaults.standard.string(forKey: "timerSound") ?? TimerSound.drum.rawValue
        let sound = TimerSound(rawValue: soundRaw) ?? .drum

        audioPlayer = sound.play()
    }

    private func scheduleNotification(at end: Date) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                self.addNotificationRequest(at: end)
            case .notDetermined:
                UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound]) { granted, _ in
                        if granted { self.addNotificationRequest(at: end) }
                    }
            default:
                break
            }
        }
    }

    private func addNotificationRequest(at end: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Rest complete"
        content.body = "Time to get back to work."
        let soundRaw = UserDefaults.standard.string(forKey: "timerSound") ?? TimerSound.drum.rawValue
        let sound = TimerSound(rawValue: soundRaw) ?? .drum
        content.sound = sound == .none ? nil : UNNotificationSound(named: UNNotificationSoundName(sound.rawValue))
        // 2-second buffer gives the foreground Timer tick time to cancel this
        // notification before it fires when the app is active.
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, end.timeIntervalSinceNow) + 2,
            repeats: false
        )
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notificationId])
        center.add(request)
    }

    func formattedTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    var formattedTimeRemaining: String {
        formattedTime(timeRemaining)
    }
}
