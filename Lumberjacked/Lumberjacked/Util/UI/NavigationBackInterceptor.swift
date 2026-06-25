//
//  NavigationBackInterceptor.swift
//  Lumberjacked
//

import SwiftUI

/// Embeds a UIViewController that, when dirty, intercepts the interactive pop
/// gesture recognizer and calls `onAttemptedPop` instead of allowing navigation.
/// Embed this as `.background(NavigationBackInterceptor(...))`.
struct NavigationBackInterceptor: UIViewControllerRepresentable {
    let isDirty: Bool
    let onAttemptedPop: () -> Void

    func makeUIViewController(context: Context) -> Controller {
        Controller()
    }

    func updateUIViewController(_ controller: Controller, context: Context) {
        controller.isDirty = isDirty
        controller.onAttemptedPop = onAttemptedPop
    }

    func makeCoordinator() {}

    class Controller: UIViewController, UIGestureRecognizerDelegate {
        var isDirty = false
        var onAttemptedPop: () -> Void = {}
        weak var originalGestureDelegate: (UIGestureRecognizerDelegate)?

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            guard let nav = navigationController else { return }
            let recognizer = nav.interactivePopGestureRecognizer
            originalGestureDelegate = recognizer?.delegate
            recognizer?.delegate = self
        }

        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            // Only restore if this VC was actually popped (not covered by a push)
            if isMovingFromParent || isBeingDismissed {
                navigationController?.interactivePopGestureRecognizer?.delegate = originalGestureDelegate
            }
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard isDirty else {
                return (navigationController?.viewControllers.count ?? 0) > 1
            }
            DispatchQueue.main.async { self.onAttemptedPop() }
            return false
        }
    }
}
