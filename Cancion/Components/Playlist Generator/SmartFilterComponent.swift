//
//  SmartFilterComponent.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/21/24.
//

import SwiftUI

struct SmartFilterComponent: View {
    var title: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.naranja)
                .shadow(radius: 2)
            HStack {
                Text(title)
                    .font(.caption2)
                    .fontWeight(.black)
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2)
            }
            .padding(.horizontal, 8)
            .foregroundStyle(.white)
            .bold()
        }
        .frame(height: 55)
    }
}

struct SmartFilterTextField: View {
    @Binding var text: String
    @Binding var filterLocked: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(filterLocked ? .naranja : .clear)
                .stroke(.naranja, lineWidth: 2)
            TextField("|", text: $text)
                .font(.caption.bold())
                .foregroundStyle(filterLocked ? .white : .naranja)
                .padding(.horizontal)
        }
        .bold()
        .frame(height: 55)
    }
}

#Preview {
    SmartFilterComponent(title: "GOVNAH!")
}
