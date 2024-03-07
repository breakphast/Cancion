//
//  SongList.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/19/24.
//

import SwiftUI
import MusicKit

struct SongList: View {
    @Environment(SongListViewModel.self) var viewModel
    @Environment(HomeViewModel.self) var homeViewModel
    @State private var text: String = ""
    @State var scrollID: Int?
    
    var songs: [Song] {
        switch viewModel.playCountAscending {
        case false:
            return homeViewModel.songService.sortedSongs.sorted { $0.playCount ?? 0 > $1.playCount ?? 0 }
        case true:
            return homeViewModel.songService.sortedSongs.sorted { $1.playCount ?? 0 > $0.playCount ?? 0 }
        }
    }
    
    var body: some View {
        VStack {
            navHeaderItems
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    songSearchTextField
                    headerItems
                        .id(33)
                    songList
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.never)
            .scrollPosition(id: $scrollID)
            .scrollTargetBehavior(.viewAligned)
            .disabled(viewModel.searchActive)
            .blur(radius: viewModel.searchActive ? 5 : 0)
            .contentMargins(16, for: .scrollContent)
            .task {
                scrollID = 33
            }
        }
        .offset(x: homeViewModel.moveSet + UIScreen.main.bounds.width)
        .padding(.horizontal)
    }
    
    private var navHeaderItems: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(.clear)
                    .frame(width: 44)
            }
            
            Spacer()
            
            Text("Desmond's Songs")
                .foregroundStyle(.oreo)
                .font(.title2.bold())
                .fontDesign(.rounded)
                .frame(maxWidth: .infinity)
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(.oreo)
                    .frame(width: 44)
                    .shadow(radius: 2)
                Image(systemName: "folder.fill.badge.gearshape")
                    .bold()
                    .foregroundStyle(.white)
            }
            .onTapGesture {
                withAnimation(.bouncy(duration: 0.4)) {
                    homeViewModel.moveSet -= UIScreen.main.bounds.width
                }
            }
        }
        .padding(.top)
        .padding(.bottom, 8)
        .blur(radius: viewModel.searchActive ? 5 : 0)
    }
    private var songSearchTextField: some View {
        TextField("", text: $text)
            .textFieldStyle(CustomTextFieldStyle(text: $text, placeholder: "Search for song", icon: "magnifyingglass"))
            .autocorrectionDisabled()
            .padding(.vertical, 8)
            .onChange(of: text) { _, _ in
                text = text
                viewModel.filterSongsByText(text: text, songs: &homeViewModel.songService.sortedSongs, songItems: homeViewModel.songService.searchResultSongs, using: homeViewModel.songService.sortedSongs)
            }
    }
    private var headerItems: some View {
        HStack {
            Text("RANK")
            
            Spacer()
            
            Button {
                viewModel.playCountAscending.toggle()
            } label: {
                HStack {
                    Text("PLAYS")
                    Image(systemName: "chevron.down")
                        .bold()
                        .rotationEffect(.degrees(viewModel.playCountAscending ? 180 : 0))
                }
            }
        }
        .font(.subheadline.bold())
        .opacity(0.7)
        .padding(.vertical, 8)
    }
    private var songList: some View {
        LazyVStack {
            ForEach(Array(songs.enumerated()), id: \.offset) { index, song in
                SongListRow(song: song, index: homeViewModel.songService.sortedSongs.firstIndex(where: {$0.id == song.id}) ?? 0)
                    .onTapGesture {
                        Task {
                            await homeViewModel.handleSongSelected(song: song)
                        }
                    }
            }
        }
    }
}

#Preview {
    SongList()
        .environment(SongService())
        .environment(SongListViewModel())
}
