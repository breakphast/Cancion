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
                .foregroundStyle(.oreo.opacity(0.9))
                .fontWeight(.semibold)
                .font(.title2)
            
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(.oreo.opacity(0.9))
                    .font(.title2.bold())
            }
        }
    }
    
    private var checkbox: some View {
        Button {
            withAnimation {
                if let icon {
                    smartRules.toggle()
                }
                selected.toggle()
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(selected ? .oreo.opacity(0.9) : .white)
                    .frame(width: 44, height: 44)
                    .shadow(radius: 2)
                
                Image(systemName: "checkmark")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
                    .opacity(selected ? 1 : 0)
            }
        }
    }
}

#Preview {
    ZStack {
        FilterCheckbox(title: "Artist", icon: nil, cornerRadius: 12, strokeColor: .oreo, smartRules: .constant(true))
    }
}
