//
//  SmartFilterComponent.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/21/24.
//

import SwiftUI

struct SmartFilterComponent: View {
    @Binding var title: String
    let type: DropdownType
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(type == .smartFilter ? .white : .oreo)
                .shadow(radius: 2)
            HStack {
                Text(title)
                    .font(.caption2)
                    .fontWeight(.black)
                if type != .limitInt {
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                }
            }
            .padding(.horizontal, 8)
            .foregroundStyle(type == .smartFilter ? .oreo : .white)
            .bold()
        }
        .frame(height: 44)
    }
}

struct SmartFilterTextField: View {
    @Binding var text: String
    @Binding var filterSet: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(filterSet ? .oreo : .oreo.opacity(0.1))
                .shadow(radius: 2)
            TextField("", text: $text)
                .font(.caption.bold())
                .foregroundStyle(filterSet ? .white : .oreo)
                .padding(.leading, 8)
                .padding(.trailing)
        }
        .bold()
        .frame(height: 44)
    }
}

#Preview {
    SmartFilterComponent(title: .constant("GOVNAH!"), type: .limit)
}
