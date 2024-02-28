//
//  CustomDivider.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/27/24.
//

import SwiftUI

struct CustomDivider: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .frame(height: 1)
//            .padding(.leading, 72)
            .foregroundStyle(.secondary.opacity(0.2))
    }
}

#Preview {
    CustomDivider()
}
