//
//  RestTimerEnvironment.swift
//  Lumberjacked
//

import Combine
import SwiftUI

@Observable
class RestTimerEnvironment {
    var activeSetId: UUID? = nil
    var timeRemaining: Int = 0
    var totalTime: Int = 0
    var isRunning: Bool = false
    var showTimerAlert: Bool = false

    private var timerCancellable: AnyCancellable?

    func start(seconds: Int, setId: UUID) {
        timerCancellable?.cancel()
        activeSetId = setId
        totalTime = seconds
        timeRemaining = seconds
        isRunning = true
        showTimerAlert = false

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.isRunning = false
                    self.activeSetId = nil
                    self.timerCancellable?.cancel()
                    self.showTimerAlert = true
                }
            }
    }

    func cancel() {
        timerCancellable?.cancel()
        isRunning = false
        activeSetId = nil
        timeRemaining = 0
        totalTime = 0
    }

    func formattedTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    var formattedTimeRemaining: String {
        formattedTime(timeRemaining)
    }
}
