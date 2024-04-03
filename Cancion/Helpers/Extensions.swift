//
//  Extensions.swift
//  Cancion
//
//  Created by Desmond Fitch on 3/27/24.
//

import SwiftUI

extension View {
    @ViewBuilder func conditionalFrame(isZero: Bool, height: CGFloat, alignment: Alignment) -> some View {
        if isZero {
            self.frame(height: height, alignment: alignment)
        } else {
            self // Do not modify the view if isZero is false
        }
    }
}

extension CGFloat {
    func formatToThreeDecimals() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 3
        formatter.maximumFractionDigits = 3
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
