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
    let filter: SongFilterModel
    
    @State var filterText = ""
    @State var filterSet: Bool = false
    
    var body: some View {
        ZStack {
            HStack {
                Dropdown(filter: filter, conditional: false, options: PlaylistGeneratorViewModel.options, selection: FilterTitle.artist.rawValue, type: .smartFilter)
                Dropdown(filter: filter, conditional: true, options: PlaylistGeneratorViewModel.conditionals, selection: ConditionalTitle.equal.rawValue, type: .smartFilter)
                SmartFilterTextField(text: $filterText, filterSet: $filterSet)
                    .onChange(of: filterText) { oldValue, newValue in
                        handleSmartFilterText()
                    }
                addFilterButton
            }
        }
    }
    
    private var addFilterButton: some View {
        HStack(spacing: 4) {
            if !filterSet {
                Button {
                    withAnimation(.bouncy) {
                        songService.filters.append(TitleFilter(value: "", condition: .contains))
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
                .animation(.none, value: songService.filters.count)
            }
            
            Button {
                withAnimation(.bouncy) {
                    songService.filters.removeAll(where: { $0.id == filter.id })
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
        playlistViewModel.filters2.enumerated().forEach { index, filterModel in
            if filterModel.id == filter.id {
                songService.filters[index].value = filterText
            }
        }
        if let filter = playlistViewModel.filters2.first {
            filter.value = filterText
        }
    }
}
