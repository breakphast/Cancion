//
//  Checkbox.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/21/24.
//

import SwiftUI

struct FilterCheckbox: View {
    let title: String
    let icon: String?
    let cornerRadius: CGFloat
    let strokeColor: Color
    var selected = false
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(strokeColor, lineWidth: 3)
                    .frame(width: 22, height: 22)
                
                Image(systemName: "checkmark")
                    .fontWeight(.black)
                    .font(.caption2)
                    .foregroundStyle(.naranja)
                    .opacity(selected ? 1 : 0)
            }
            Text(title)
                .foregroundStyle(.oreo)
                .fontWeight(.semibold)
                .bold()
            
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(strokeColor)
                    .font(.title3.bold())
            }
        }
    }
}

#Preview {
    ZStack {
        FilterCheckbox(title: "Artist", icon: nil, cornerRadius: 12, strokeColor: .naranja)
    }
}
