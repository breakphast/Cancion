//
//  SongList.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/19/24.
//

import SwiftUI
import MusicKit

enum SongSortOption: String {
    case dateAdded = "Date Added"
    case lastPlayed = "Last Played"
    case plays = "Plays"
}

enum PlaylistSongSortOption: String {
    case dateAdded = "date added"
    case lastPlayed = "last played"
    case plays = "plays"
    case title = "title"
    case artist = "artist"
}

struct SongList: View {
    @Environment(SongListViewModel.self) var viewModel
    @Environment(HomeViewModel.self) var homeViewModel
    @Environment(SongService.self) var songService
    @State private var text: String = ""
    @State var scrollID: Int?
    @FocusState var isFocused: Bool
    private var sortOption: SongSortOption {
        return homeViewModel.songSort
    }
    
    var songs: [Song] {
        switch viewModel.playCountAscending {
        case false:
            switch sortOption {
            case .dateAdded:
                return songService.sortedSongs.filter { $0.libraryAddedDate != nil }.sorted { $0.libraryAddedDate! > $1.libraryAddedDate! }
            case .plays:
                return songService.sortedSongs.sorted { $0.playCount ?? 0 > $1.playCount ?? 0 }
            case .lastPlayed:
                return songService.sortedSongs.filter { $0.lastPlayedDate != nil }.sorted { $0.lastPlayedDate! > $1.lastPlayedDate! }
            }
        case true:
            switch sortOption {
            case .dateAdded:
                return songService.sortedSongs.filter { $0.libraryAddedDate != nil }.sorted { $0.libraryAddedDate! < $1.libraryAddedDate! }
            case .plays:
                return songService.sortedSongs.sorted { $0.playCount ?? 0 < $1.playCount ?? 0 }
            case .lastPlayed:
                return songService.sortedSongs.filter { $0.lastPlayedDate != nil }.sorted { $0.lastPlayedDate! < $1.lastPlayedDate! }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            VStack {
                navHeaderItems
                    .padding(.horizontal, 24)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        songSearchTextField
                            .focused($isFocused)
                        headerItems
                            .zIndex(2000)
                            .id(33)
                        songList
                    }
                    .padding(.horizontal, 24)
                    .scrollTargetLayout()
                }
                .simultaneousGesture(homeViewModel.swipeGesture)
                .scrollIndicators(.never)
                .scrollPosition(id: $scrollID)
                .scrollTargetBehavior(.viewAligned)
                .scrollDismissesKeyboard(.interactively)
                .disabled(viewModel.searchActive)
                .blur(radius: viewModel.searchActive ? 5 : 0)
                .task {
                    scrollID = 33
                }
            }
        }
        .offset(x: homeViewModel.moveSet + UIScreen.main.bounds.width)
        .onChange(of: homeViewModel.currentScreen) { _, _ in
            isFocused = false
        }
    }
    
    private var navHeaderItems: some View {
        HStack {
            Button {
                withAnimation {
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
            
            Text("My Songs")
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
                withAnimation {
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
                viewModel.filterSongsByText(text: text, songs: &songService.sortedSongs, using: songService.ogSongs)
            }
            .padding(.horizontal)
    }
    private var headerItems: some View {
        HStack {
            Spacer()
            
            SortDropdown(options: ["Plays", "Date Added", "Last Played"])
                .frame(maxWidth: 100)
                .frame(height: 33)
            Image(systemName: "chevron.down")
                .font(.title3.bold())
                .rotationEffect(.degrees(viewModel.playCountAscending ? 180 : 0))
                .contentShape(Circle())
                .onTapGesture {
                    viewModel.playCountAscending.toggle()
                }
        }
        .font(.subheadline.bold())
        .padding(.vertical, 8)
    }
    private var songList: some View {
        LazyVStack {
            ForEach(Array(songs.enumerated()), id: \.offset) { index, song in
                SongListRow(song: song, index: songService.sortedSongs.firstIndex(where: {$0.id == song.id}) ?? 0)
                    .onTapGesture {
                        Task {
                            let upperBound = index + 20 > songs.count ? songs.count : index + 20
                            let _ = await homeViewModel.handleSongSelected(song: song, songs: Array(songs[index..<upperBound]))
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
