//
//  LimitToStack.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/21/24.
//

import SwiftUI

struct LimitToStack: View {
    let limit: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.naranja, lineWidth: 3)
                    .frame(width: 22, height: 22)
                limitToStack
            }
            selectedByStack
        }
    }
    
    private var limitToStack: some View {
        HStack {
            Text("Limit to")
                .bold()
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.naranja, lineWidth: 3)
                Text("\(limit)")
                    .font(.caption.bold())
                    .foregroundStyle(.naranja)
            }
            .frame(width: 33, height: 33)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.naranja)
                HStack {
                    Text("items")
                        .font(.caption.bold())
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                }
                .padding(.horizontal)
                .foregroundStyle(.white)
                .bold()
            }
            .frame(height: 33)
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(.oreo)
    }
    
    private var selectedByStack: some View {
        HStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.clear, lineWidth: 3)
                .frame(width: 22, height: 22)
            HStack {
                Text("selected by")
                    .bold()
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.naranja)
                    HStack {
                        Text("most played")
                            .font(.caption.bold())
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption2)
                    }
                    .padding(.horizontal)
                    .foregroundStyle(.white)
                    .bold()
                }
                .frame(height: 33)
                .frame(maxWidth: .infinity)
            }
            .foregroundStyle(.oreo)
        }
    }
}

#Preview {
    LimitToStack(limit: 24)
}
