//
//  CapsuleButtonStyle.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 9/26/25.
//

import SwiftUI

struct CapsuleButtonStyle: ButtonStyle {
    public static var horizontalPadding: CGFloat = 18
    public static var verticalPadding: CGFloat = 12
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(EdgeInsets(top: Self.verticalPadding, leading: Self.horizontalPadding, bottom: Self.verticalPadding, trailing: Self.horizontalPadding))
            .foregroundColor(.brandPrimaryText)
            .background(configuration.isPressed ? .brandSecondaryLight : .brandSecondary)
            .clipShape(.capsule)

    }
}

extension ButtonStyle where Self == CapsuleButtonStyle {
    static var capsule: CapsuleButtonStyle {
        return CapsuleButtonStyle()
    }
}
