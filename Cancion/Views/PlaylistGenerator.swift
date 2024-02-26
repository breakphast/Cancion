//
//  PlaylistGenerator.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/20/24.
//

import SwiftUI
import MusicKit

struct PlaylistGenerator: View {
    @Environment(SongService.self) var songService
    @Binding var moveSet: CGFloat
    @State var mainZIndex: CGFloat = 1000
    @State private var playlistName = ""
    @State private var smartRulesActive = true
    @State var filterText = ""
    
    var body: some View {
        ZStack {
            VStack {
                headerTitle
                    .fontDesign(.rounded)
                    .padding(.horizontal, 12)
                ScrollView {
                    VStack {
                        playlistCover
                            .padding(.top, 16)
                        playlistTitle
                            .padding(.top, 24)
                        
                            VStack(alignment: .leading) {
                                smartFilters
                                LimitToStack(filter: songService.limitFilter)
                                divider
                                FilterCheckbox(title: "Live updating", icon: nil, cornerRadius: 12, strokeColor: .oreo, smartRules: $smartRulesActive)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top)
                    }
                }
                .scrollIndicators(.never)
                .safeAreaPadding(.bottom, 24)
            }
            .padding(.top)
        }
    }
    private var smartFilters: some View {
        VStack(alignment: .leading, spacing: 24) {
            FilterCheckbox(title: "Smart Rules", icon: "questionmark.circle.fill", cornerRadius: 12, strokeColor: .oreo, smartRules: $smartRulesActive)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(songService.filters.indices, id: \.self) { index in
                    SmartFilterStack(filter: songService.filters[index])
                        .disabled(!smartRulesActive)
                        .zIndex(Double(100 - index))
                }
                .blur(radius: !smartRulesActive ? 2 : 0)
                
                RoundedRectangle(cornerRadius: 1)
                    .frame(height: 1)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .foregroundStyle(.secondary.opacity(0.2))
            }
        }
        .zIndex(10)
    }
    
    private var playlistCover: some View {
        Image(.wap)
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .frame(maxWidth: .infinity)
            .shadow(radius: 5)
            .padding(.horizontal, 24)
    }
    
    private var headerTitle: some View {
        ZStack {
            Text("Playlist Generator")
                .foregroundStyle(.oreo)
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .center)
            
            Button {
                withAnimation(.bouncy(duration: 0.4)) {
                    moveSet += UIScreen.main.bounds.width
                    let combinedFilter = CompositeFilter(filters: songService.filters)
                    print(songService.filters.map { $0.value })
                    let filteredSongs = smartFilterSongs(songs: songService.sortedSongs, using: combinedFilter)
                    print(filteredSongs.map {$0.title})
                }
            } label: {
                Image(systemName: "checkmark")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
                    .background(
                        Circle()
                            .fill(.naranja.opacity(0.9))
                            .shadow(radius: 2)
                    )
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .tint(.white)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var playlistTitle: some View {
        VStack(alignment: .center, spacing: 8) {
            TextField("Playlist Name", text: $playlistName)
                .foregroundStyle(.oreo)
                .font(.title.bold())
                .lineLimit(1)
                .padding(.horizontal, 24)
                .autocorrectionDisabled()
                
            RoundedRectangle(cornerRadius: 2)
                .frame(height: 1)
                .foregroundStyle(.gray.opacity(0.2))
                .padding(.horizontal, 24)
        }
    }
    
    private var divider: some View {
        RoundedRectangle(cornerRadius: 1)
            .frame(height: 1)
            .padding(.horizontal)
            .padding(.vertical, 12)
            .foregroundStyle(.secondary.opacity(0.2))
    }
    
    private func smartFilterSongs(songs: [Song], using filter: SongFilterModel) -> [Song] {
        return songs.filter { filter.matches(song: $0) }
    }
    
    private func calculateScrollViewHeight() -> CGFloat {
        let filterHeight: CGFloat = 48 + 64
        let spacing: CGFloat = 8
        let totalHeight = CGFloat(songService.filters.count) * filterHeight + CGFloat(songService.filters.count - 1) * spacing
        print(UIScreen.main.bounds.height)
        return min(totalHeight, UIScreen.main.bounds.height * 0.25)
    }
}

#Preview {
    PlaylistGenerator(moveSet: .constant(.zero))
        .environment(SongService())
}

