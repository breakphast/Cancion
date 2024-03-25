//
//  PlaylistView.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/27/24.
//

import SwiftUI
import MusicKit

struct PlaylistView: View {
    @Environment(SongService.self) var songService
    @Environment(HomeViewModel.self) var homeViewModel
    @Environment(PlaylistGeneratorViewModel.self) var playlistGeneratorViewModel
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State var viewModel = PlaylistViewModel()
    @State private var text: String = ""
    @State var filteredSongs: [Song] = []
    var playCountAscending = false
    
    @FocusState var isFocused: Bool
    @Binding var showView: Bool
    @State private var showGenerator = false
    @State private var scrollID: String?
    @State private var coverImage: Image?
    
    var playlist: Playlista
    
    private var sortOption: LimitSortType? {
        return homeViewModel.playlistSongSort
    }
    
    @State var sortTitle: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            navHeaderItems
                .padding(.horizontal, 24)
            
            ScrollView {
                VStack(alignment: .leading) {
                    songSearchTextField
                    playlistCover
                        .id("cover")
                    headerItems
                    songList
                }
                .padding(.top, 4)
                .padding(.horizontal, 24)
            }
            .scrollIndicators(.never)
            .scrollPosition(id: $scrollID)
            .disabled(viewModel.searchActive)
            .blur(radius: viewModel.searchActive ? 5 : 0)
        }
        .frame(maxWidth: .infinity)
        .gesture(homeViewModel.swipeGesture)
        .fullScreenCover(isPresented: $showGenerator) {
            EditPlaylistView(playlist: playlist)
                .environment(playlistGeneratorViewModel)
        }
        .onChange(of: homeViewModel.currentScreen) { _, _ in
            isFocused = false
        }
        .onAppear {
            scrollID = "cover"
        }
        .onChange(of: sortOption, { oldValue, newValue in
            switch sortOption {
            case .artist:
                sortTitle = PlaylistSongSortOption.artist.rawValue.uppercased()
            case .mostPlayed:
                sortTitle = PlaylistSongSortOption.plays.rawValue.uppercased()
            case .lastPlayed:
                sortTitle = PlaylistSongSortOption.lastPlayed.rawValue.uppercased()
            case .mostRecentlyAdded:
                sortTitle = PlaylistSongSortOption.dateAdded.rawValue.uppercased()
            case .title:
                sortTitle = PlaylistSongSortOption.title.rawValue.uppercased()
            default:
                sortTitle = PlaylistSongSortOption.plays.rawValue.uppercased()
            }
        })
        .task {
            playlistGeneratorViewModel.assignViewModelValues(playlist: playlist)
            if let coverData = playlist.cover {
                playlistGeneratorViewModel.coverData = coverData
                if let uiImage = UIImage(data: coverData) {
                    coverImage = Image(uiImage: uiImage)
                }
            }
            if let limitSortType = playlist.limitSortType {
                switch LimitSortType(rawValue: limitSortType) {
                case .artist:
                    homeViewModel.playlistSongSort = .artist
                    sortTitle = PlaylistSongSortOption.artist.rawValue.uppercased()
                case .mostPlayed:
                    homeViewModel.playlistSongSort = .mostPlayed
                    sortTitle = PlaylistSongSortOption.plays.rawValue.uppercased()
                case .lastPlayed:
                    homeViewModel.playlistSongSort = .lastPlayed
                    sortTitle = PlaylistSongSortOption.lastPlayed.rawValue.uppercased()
                case .mostRecentlyAdded:
                    homeViewModel.playlistSongSort = .mostRecentlyAdded
                    sortTitle = PlaylistSongSortOption.dateAdded.rawValue.uppercased()
                case .title:
                    homeViewModel.playlistSongSort = .title
                    sortTitle = PlaylistSongSortOption.title.rawValue.uppercased()
                default:
                    homeViewModel.playlistSongSort = .mostPlayed
                    sortTitle = PlaylistSongSortOption.plays.rawValue.uppercased()
                }
            }
            
            if playlist.liveUpdating {
                let updatedSongs = await playlistGeneratorViewModel.fetchMatchingSongIDs(songs: homeViewModel.songService.sortedSongs, filters: playlist.filters, matchRules: playlist.matchRules, limitType: playlist.limitType)
                if updatedSongs != playlist.songs && !updatedSongs.isEmpty {
                    playlist.songs = updatedSongs
                }
            }
        }
    }
    
    private var navHeaderItems: some View {
        HStack {
            Button {
                withAnimation(.bouncy(duration: 0.4)) {
                    dismiss()
                    showView = false
                    homeViewModel.playlistSongSort = nil
                }
                withAnimation(.bouncy(duration: 0.4)) {
                    Task {
                        await playlistGeneratorViewModel.resetViewModelValues()
                    }
                    dismiss()
                    showView = false
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.oreo)
                        .frame(width: 44)
                        .shadow(radius: 2)
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                        .font(.headline)
                        .fontWeight(.heavy)
                }
            }
            
            Spacer()
            
            Text(playlist.name)
                .foregroundStyle(.oreo)
                .font(.title2.bold())
                .fontDesign(.rounded)
                .frame(maxWidth: .infinity)
            
            Spacer()
            
            Button {
                withAnimation(.bouncy(duration: 0.4)) {
                    showGenerator.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.oreo)
                        .frame(width: 44)
                        .shadow(radius: 2)
                    Image(systemName: "pencil")
                        .foregroundStyle(.white)
                        .font(.headline)
                        .fontWeight(.black)
                }
            }
        }
        .padding(.top)
        .blur(radius: viewModel.searchActive ? 5 : 0)
    }
    private var songSearchTextField: some View {
        TextField("", text: $text)
            .textFieldStyle(CustomTextFieldStyle(text: $text, placeholder: "Search for song", icon: "magnifyingglass"))
            .autocorrectionDisabled()
            .padding(.horizontal)
            .focused($isFocused)
    }
    private var headerItems: some View {
        HStack {
            Spacer()
            
            Button {
                viewModel.playCountAscending.toggle()
                
            } label: {
                HStack(spacing: 4) {
                    Text(sortTitle)
                    Image(systemName: "chevron.down")
                        .bold()
                        .rotationEffect(.degrees(viewModel.playCountAscending ? 180 : 0))
                }
            }
        }
        .font(.subheadline.bold())
        .opacity(0.7)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    private var playlistCover: some View {
        ZStack {
            if let coverImage {
                coverImage
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.white)
                            .shadow(radius: 3)
                    )
                    .padding()
            } else if let songID = playlist.songs.first, let songID2 = playlist.songs.last, let song1 = Array(homeViewModel.songService.searchResultSongs).first(where: { $0.id.rawValue == songID }), let song2 = Array(homeViewModel.songService.searchResultSongs).first(where: { $0.id.rawValue == songID2 }) {
                if let artwork1 = song1.artwork, let artwork2 = song2.artwork  {
                    HStack(spacing: 0) {
                        ArtworkImage(artwork1, width: 200)
                        ArtworkImage(artwork2, width: 200)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 200)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.white)
                            .shadow(radius: 3)
                    )
                    .padding()
                } else {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.oreo.opacity(0.6))
                        .shadow(radius: 5)
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: 200)
                        .padding(.vertical)
                }
            }
        }
    }
    private var songList: some View {
        VStack {
            ForEach(Array(songs.enumerated()), id: \.offset) { index, song in
                SongListRow(song: song, index: viewModel.playCountAscending ? ((songs.count - 1) - index) : index)
                    .onTapGesture {
                        Task {
                            await homeViewModel.handleSongSelected(song: song, songs: homeViewModel.songService.playlistSongs)
                        }
                    }
            }
        }
    }
    var songs: [Song] {
        switch viewModel.playCountAscending {
        case false:
            switch sortOption {
            case .mostRecentlyAdded:
                return homeViewModel.songService.playlistSongs.filter { $0.libraryAddedDate != nil }.sorted { $0.libraryAddedDate! > $1.libraryAddedDate! }
            case .mostPlayed:
                return homeViewModel.songService.playlistSongs.sorted { $0.playCount ?? 0 > $1.playCount ?? 0 }
            case .lastPlayed:
                return homeViewModel.songService.playlistSongs.filter { $0.lastPlayedDate != nil }.sorted { $0.lastPlayedDate! > $1.lastPlayedDate! }
            case .title:
                return homeViewModel.songService.playlistSongs.sorted { $0.title.lowercased() < $1.title.lowercased()}
            case .artist:
                return homeViewModel.songService.playlistSongs.sorted { $0.artistName.lowercased() < $1.artistName.lowercased()}
            default:
                return homeViewModel.songService.playlistSongs.sorted { $0.playCount ?? 0 > $1.playCount ?? 0 }
            }
        case true:
            switch sortOption {
            case .mostRecentlyAdded:
                return homeViewModel.songService.playlistSongs.filter { $0.libraryAddedDate != nil }.sorted { $0.libraryAddedDate! < $1.libraryAddedDate! }
            case .mostPlayed:
                return homeViewModel.songService.playlistSongs.sorted { $0.playCount ?? 0 < $1.playCount ?? 0 }
            case .lastPlayed:
                return homeViewModel.songService.playlistSongs.filter { $0.lastPlayedDate != nil }.sorted { $0.lastPlayedDate! < $1.lastPlayedDate! }
            case .title:
                return homeViewModel.songService.playlistSongs.sorted { $0.title.lowercased() > $1.title.lowercased()}
            case .artist:
                return homeViewModel.songService.playlistSongs.sorted { $0.artistName.lowercased() > $1.artistName.lowercased()}
            default:
                return homeViewModel.songService.playlistSongs.sorted { $0.playCount ?? 0 < $1.playCount ?? 0 }
            }
        }
    }
}
