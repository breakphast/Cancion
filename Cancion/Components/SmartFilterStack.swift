//
//  SmartFilterStack.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/21/24.

import SwiftUI
import SwiftData

struct SmartFilterStack: View {
    let filter: Filter
    @Binding var filters: [Filter]?
    @Binding var limit: Int?
    @Binding var limitType: String?
    @Binding var limitSortType: String?
    @Binding var matchRules: String?
    @Binding var dropdownActive: Bool
    
    @State var filterText = ""
//    @Binding var filterss: [Filter]
    
    var isDateStack: Bool {
        return [FilterType.dateAdded.rawValue, FilterType.lastPlayedDate.rawValue].contains(filter.type)
    }
    
    var body: some View {
        ZStack {
            HStack {
                Dropdown(filter: filter, type: .smartFilter, matchRules: $matchRules, filters: $filters, limit: $limit, limitType: $limitType, limitSortType: $limitSortType, dropdownActive: $dropdownActive)
                Dropdown(filter: filter, type: .smartCondition, matchRules: $matchRules, filters: $filters, limit: $limit, limitType: $limitType, limitSortType: $limitSortType, dropdownActive: $dropdownActive)
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
                withAnimation {
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
                withAnimation {
                    guard let count = filters?.count, count > 1 else { return }
                    filters?.removeAll(where: { $0.id == filter.id })
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
