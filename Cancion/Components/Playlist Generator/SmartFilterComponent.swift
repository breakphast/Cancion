//
//  SmartFilterComponent.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/21/24.
//

import SwiftUI

struct SmartFilterComponent: View {
    @Binding var title: String
    var limit: Int
    let type: DropdownType
    
    var dropS: Bool {
        return limit == 1 && type == .limitType
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill((type == .smartFilter || type == .smartCondition) ? .white : .oreo)
                .shadow(radius: 2)
            HStack {
                Text(dropS ? String(title.dropLast()) : title)
                    .font(.caption2)
                    .fontWeight(.black)
                if type != .limit {
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                }
            }
            .padding(.horizontal, 8)
            .foregroundStyle((type == .smartFilter || type == .smartCondition) ? .oreo : .white)
            .bold()
        }
        .frame(height: 44)
    }
}

struct SmartFilterTextField: View {
    @Binding var text: String
    let type: SmartFilterTextType
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(type == .filter ? .oreo.opacity(0.1) : .oreo)
                .shadow(radius: 2)
            TextField("", text: $text)
                .font(.caption.bold())
                .foregroundStyle(type == .filter ? .oreo : .white)
                .padding(.leading, 8)
                .padding(.trailing)
        }
        .bold()
        .frame(height: 44)
    }
}

enum SmartFilterTextType {
    case filter
    case limit
}

//#Preview {
//    SmartFilterComponent(title: .constant("GOVNAH!"), type: .limit)
//}
