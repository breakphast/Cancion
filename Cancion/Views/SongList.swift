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
    @FocusState var isFocused: Bool
    
    var songs: [Song] {
        switch viewModel.playCountAscending {
        case false:
            return homeViewModel.songService.sortedSongs.sorted { $0.playCount ?? 0 > $1.playCount ?? 0 }
        case true:
            return homeViewModel.songService.sortedSongs.sorted { $1.playCount ?? 0 > $0.playCount ?? 0 }
        }
    }
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.000001).ignoresSafeArea()
            VStack {
                navHeaderItems
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        songSearchTextField
                            .focused($isFocused)
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
                .task {
                    scrollID = 33
                }
            }
            .padding(.horizontal, 24)
        }
        .gesture(homeViewModel.swipeGesture)
        .offset(x: homeViewModel.moveSet + UIScreen.main.bounds.width)
        .onChange(of: homeViewModel.currentScreen) { _, _ in
            isFocused = false
        }
    }
    
    private var navHeaderItems: some View {
        HStack {
            Button {
                withAnimation(.bouncy(duration: 0.4)) {
                    homeViewModel.currentScreen = .player
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.oreo)
                        .frame(width: 44)
                        .shadow(radius: 2)
                    Image(systemName: "waveform.circle.fill")
                        .foregroundStyle(.white)
                        .font(.title3)
                        .fontWeight(.heavy)
                }
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
                    homeViewModel.currentScreen = .playlists
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
            .padding(.horizontal)
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
