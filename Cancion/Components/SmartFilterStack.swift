//
//  SmartFilterStack.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/21/24.

import SwiftUI
import SwiftData

struct SmartFilterStack: View {
    let filter: Filter
    let editing: Bool
    @Binding var filters: [Filter]?
    @Binding var limit: Int?
    
    @State var filterText = ""
//    @Binding var filterss: [Filter]
    
    var isDateStack: Bool {
        return [FilterType.dateAdded.rawValue, FilterType.lastPlayedDate.rawValue].contains(filter.type)
    }
    
    var body: some View {
        ZStack {
            HStack {
                Dropdown(filter: filter, type: .smartFilter, editing: editing, filters: $filters, limit: $limit)
                Dropdown(filter: filter, type: .smartCondition, editing: editing, filters: $filters, limit: $limit)
                if isDateStack {
                    DatePickr(filter: filter)
                        .padding(.trailing, 4)
                } else {
                    SmartFilterTextField(text: $filterText, type: .filter)
                        .onChange(of: filterText) { oldValue, newValue in
                            handleSmartFilterText(filters: filters ?? [])
                        }
                }
                addFilterButton
            }
        }
        .task {
            filterText = filter.value
        }
    }
    
    private var addFilterButton: some View {
        HStack(spacing: 4) {
            Button {
                withAnimation(.bouncy) {
                    filters?.append(Filter())
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.oreo)
                        .shadow(radius: 1)
                    Image(systemName: "plus")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .fontWeight(.black)
                }
                .frame(width: 22, height: 44)
            }
            .animation(.none, value: filters?.count)
            
            Button {
                withAnimation(.bouncy) {
                    guard var filters, filters.count > 1 else { return }
                    filters.removeAll(where: { $0.id.uuidString == filter.id.uuidString })
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.oreo)
                        .shadow(radius: 1)
                    Image(systemName: "minus")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .fontWeight(.black)
                }
                .frame(width: 22, height: 44)
            }
        }
    }
    
    private func handleSmartFilterText(filters: [Filter]) {
        if let filter = filters.first(where: {$0.id.uuidString == filter.id.uuidString}) {
            filter.value = filterText
        }
    }
}
