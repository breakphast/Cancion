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
    
    @State private var selected = false
    @Binding var smartRules: Bool
    
    var body: some View {
        HStack {
            checkbox
            
            Text(title)
                .foregroundStyle(.oreo)
                .fontWeight(.semibold)
                .font(.title3)
            
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(.oreo)
                    .font(.subheadline.bold())
            }
        }
    }
    
    private var checkbox: some View {
        Button {
            withAnimation {
                if icon != nil { smartRules.toggle() }
                selected.toggle()
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill((icon != nil ? smartRules : selected) ? .naranja.opacity(0.9) : .white)
                    .frame(width: 33, height: 33)
                    .shadow(radius: 2)
                Image(systemName: "checkmark")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
                    .opacity((icon != nil ? smartRules : selected) ? 1 : 0)
            }
        }
    }
}

#Preview {
    ZStack {
        FilterCheckbox(title: "Artist", icon: "plus", cornerRadius: 12, strokeColor: .oreo, smartRules: .constant(true))
    }
}
