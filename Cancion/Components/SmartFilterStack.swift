//
//  SmartFilterStack.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/21/24.

import SwiftUI
import SwiftData

struct SmartFilterStack: View {
    @Environment(PlaylistGeneratorViewModel.self) var playlistViewModel
    @Environment(EditPlaylistViewModel.self) private var editPlaylistViewModel

    let filter: Filter
    
    @State var filterText = ""
    @Binding var filterss: [Filter]
    
    var isDateStack: Bool {
        return [FilterType.dateAdded.rawValue, FilterType.lastPlayedDate.rawValue].contains(filter.type)
    }
    
    var body: some View {
        ZStack {
            HStack {
                Dropdown(filter: filter, type: .smartFilter)
                Dropdown(filter: filter, type: .smartCondition)
                if isDateStack {
                    DatePickr(filter: filter)
                        .padding(.trailing, 4)
                } else {
                    SmartFilterTextField(text: $filterText, type: .filter)
                        .onChange(of: filterText) { oldValue, newValue in
                            handleSmartFilterText(filters: filterss)
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
                    filterss.append(Filter())
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
            .animation(.none, value: playlistViewModel.filters.count)
            
            Button {
                withAnimation(.bouncy) {
                    guard filterss.count > 1 else { return }
                    filterss.removeAll(where: { $0.id.uuidString == filter.id.uuidString })
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
