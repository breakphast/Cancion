//
//  SmartFilterStack.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/21/24.
//

import SwiftUI

struct SmartFilterStack: View {
    @Binding var text: String
    @Binding var filters: [FilterModel]
    @State var filterLocked = false
    var filterTitle: String
    var conditionalTitle: String
    
    var body: some View {
        ZStack {
            HStack {
                SmartFilterComponent(title: filterTitle)
                SmartFilterComponent(title: conditionalTitle)
                SmartFilterTextField(text: $text, filterLocked: $filterLocked)
                addFilterButton
            }
        }
    }
    
    private var addFilterButton: some View {
        HStack(spacing: 4) {
            if !filterLocked {
                Button {
                    withAnimation(.bouncy) {
                        filterLocked = true
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.oreo.opacity(0.9))
                            .shadow(radius: 1)
                        Image(systemName: filterLocked ? "minus" : "plus")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .fontWeight(.black)
                    }
                    .frame(width: 22, height: 33)
                }
            }
            
            Button {
                withAnimation(.bouncy) {
                    filters.removeLast(1)
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.oreo.opacity(0.9))
                        .shadow(radius: 1)
                    Image(systemName: "minus")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .fontWeight(.black)
                }
                .frame(width: 22, height: 33)
            }
        }
    }
}
