//
//  LimitToStack.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/21/24.
//

import SwiftUI

struct LimitToStack: View {
    let limit: Int
    @State var selected = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                checkbox
                limitToStack
            }
            selectedByStack
        }
    }
    
    private var checkbox: some View {
        Button {
            withAnimation {
                selected.toggle()
            }
        } label: {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(selected ? .oreo.opacity(0.9) : .white)
                .shadow(radius: 2)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundStyle(.white)
                }
        }
    }
    
    private var limitToStack: some View {
        HStack {
            Text("Limit to")
                .fontWeight(.semibold)
                .font(.title2)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.oreo.opacity(0.9))
                    .shadow(radius: 2)
                Text("\(limit)")
                    .font(.caption)
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
            }
            .frame(width: 44, height: 44)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.oreo.opacity(0.9))
                    .shadow(radius: 4)
                HStack {
                    Text("items")
                        .font(.caption)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                }
                .padding(.horizontal)
                .foregroundStyle(.white)
            }
            .fontWeight(.heavy)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(.oreo)
    }
    
    private var selectedByStack: some View {
        HStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.clear, lineWidth: 3)
                .frame(width: 44, height: 22)
            HStack {
                Text("selected by")
                    .fontWeight(.semibold)
                    .font(.title2)
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.oreo.opacity(0.9))
                        .shadow(radius: 4)
                    HStack {
                        Text("most played")
                            .font(.caption)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption2)
                    }
                    .padding(.horizontal)
                    .foregroundStyle(.white)
                }
                .fontWeight(.heavy)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
            }
            .foregroundStyle(.oreo)
        }
    }
}

#Preview {
    LimitToStack(limit: 24)
}
