//
//  SmartFilterStack.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/21/24.
//

import SwiftUI
import SwiftData

struct SmartFilterStack: View {
    @Environment(PlaylistGeneratorViewModel.self) var playlistViewModel
    let filter: FilterModel
    let playlist: Playlista
    var editing = false
    
    @State var filterText = ""
    var filters: [FilterModel]? {
        return editing ? playlist.filters : playlistViewModel.activeFilters
    }
    
    var isDateStack: Bool {
        return [FilterType.dateAdded.rawValue, FilterType.lastPlayedDate.rawValue].contains(filter.type)
    }
    
    var body: some View {
        ZStack {
            HStack {
                Dropdown(filter: filter, type: .smartFilter, playlist: playlist)
                Dropdown(filter: filter, type: .smartCondition, playlist: playlist)
                if isDateStack {
                    DatePickr(playlistGenViewModel: playlistViewModel)
                        .padding(.trailing, 4)
                } else {
                    SmartFilterTextField(text: $filterText, type: .filter)
                        .onChange(of: filterText) { oldValue, newValue in
                            if let filters { handleSmartFilterText(filters: filters) }
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
                    playlistViewModel.activeFilters.append(FilterModel())
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
            .animation(.none, value: playlistViewModel.activeFilters.count)
            
            Button {
                withAnimation(.bouncy) {
                    guard playlistViewModel.activeFilters.count > 1 else { return }
                    playlistViewModel.activeFilters.removeAll(where: { $0.id == filter.id })
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
    
    private func handleSmartFilterText(filters: [FilterModel]) {
        if let filter = filters.first(where: {$0.id.uuidString == filter.id.uuidString}) {
            filter.value = filterText
        }
    }
}
