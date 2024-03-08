//
//  SmartFilterStack.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/21/24.
//

import SwiftUI
import SwiftData

struct SmartFilterStack: View {
    @Environment(SongService.self) var songService
    @Environment(PlaylistGeneratorViewModel.self) var playlistViewModel
    let filter: FilterModel
    
    @State var filterText = ""
    
    var body: some View {
        ZStack {
            HStack {
                Dropdown(filter: filter, type: .smartFilter, playlist: playlistViewModel.genPlaylist)
                Dropdown(filter: filter, type: .smartCondition, playlist: playlistViewModel.genPlaylist)
                SmartFilterTextField(text: $filterText, type: .filter)
                    .onChange(of: filterText) { oldValue, newValue in
                        handleSmartFilterText()
                    }
                addFilterButton
            }
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
    
    private func handleSmartFilterText() {
        if let filter = playlistViewModel.activeFilters.first(where: {$0.id.uuidString == filter.id.uuidString}) {
            filter.value = filterText
        }
    }
}
