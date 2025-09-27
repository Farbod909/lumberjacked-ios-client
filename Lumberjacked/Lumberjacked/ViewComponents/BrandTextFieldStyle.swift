//
//  BrandTextFieldStyle.swift
//  Lumberjacked
//
//  Created by Farbod Rafezy on 9/26/25.
//

import SwiftUI

struct BrandTextFieldStyle: TextFieldStyle {
    public static var defaultHorizontalPadding: CGFloat = 18
    public static var defaultVerticalPadding: CGFloat = 12
    public static var defaultCornerRadius: CGFloat = 12

    var horizontalPadding = defaultHorizontalPadding
    var verticalPadding = defaultVerticalPadding
    var cornerRadius: CGFloat = defaultCornerRadius

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(EdgeInsets(top: verticalPadding, leading: horizontalPadding, bottom: verticalPadding, trailing: horizontalPadding))
            .foregroundColor(.brandPrimaryText)
            .background(.brandSecondary)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension TextFieldStyle where Self == BrandTextFieldStyle {
    static var brand: BrandTextFieldStyle {
        return BrandTextFieldStyle()
    }
}
