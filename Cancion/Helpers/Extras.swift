//
//  Helpers.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/27/24.
//

import SwiftUI
import MusicKit

struct CustomTextFieldStyle: TextFieldStyle {
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            Image(systemName: icon)
            ZStack {
                Text(placeholder)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(text.isEmpty ? 1.0 : 0)
                configuration
                    .foregroundStyle(.oreo)
            }
        }
        .bold()
        .foregroundStyle(.oreo)
        .padding(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white)
                .shadow(color: .gray.opacity(0.4), radius: 2)
        )
    }
}

struct Helpers {
    var dateFormatter = DateFormatter()
    init() {
        dateFormatter.dateFormat = "M/d/yy"
    }
}

struct AnyShape: Shape {
    private let _path: @Sendable (CGRect) -> Path

    init<S: Shape>(_ wrapped: S) {
        _path = { rect in
            wrapped.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}
