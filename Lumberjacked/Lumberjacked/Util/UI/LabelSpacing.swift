//
//  LabelSpacing.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 1/29/25.
//

import SwiftUI

struct CustomLabelSpacing: LabelStyle {
    var spacing: Double = 0.0
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}
