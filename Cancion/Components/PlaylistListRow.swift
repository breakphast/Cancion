//
//  PlaylistListRow.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/27/24.
//

import SwiftUI
import MusicKit
import SwiftData

struct PlaylistListRow: View {
    @State var playlist: Playlistt
    @Environment(PlaylistViewModel.self) var viewModel
    @Environment(SongService.self) var songService
    @Environment(PlaylistGeneratorViewModel.self) var playlistGenViewModel
    @Environment(HomeViewModel.self) var homeViewModel
    @Environment(\.modelContext) var modelContext
    @Environment(\.openURL) var openURL
    @State private var showMenu = false
    @State private var activePlaylist = false
    @State private var coverImage: Image?
    @Query var playlistas: [Playlistt]
    @Query var filtersQuery: [Filter]
    @State private var showAlert = false
    
    var song: Song? {
        if let songID = playlist.songs.first, let song = Array(songService.ogSongs).first(where: {$0.id.rawValue == songID}) {
            return song
        }
        return nil
    }
    
    var name: String {
        return playlist.name
    }
    
    var playlistURL: URL? {
        if let urlString = playlist.urlString, let url = URL(string: urlString) {
            return url
        }
        return nil
    }
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    playlistCoverIcon
                    
                    Text(name)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 4)
                        .lineLimit(1)

                }
                .onTapGesture {
                    Task { @MainActor in
                        viewModel.playlist = playlist
                        viewModel.assignSongs(sortType: homeViewModel.playlistSongSort ?? LimitSortType.artist)
                        switch LimitSortType(rawValue: playlist.limitSortType ?? LimitSortType.artist.rawValue) {
                        case .mostRecentlyAdded:
                            homeViewModel.playlistSongSort = .mostRecentlyAdded
                        case .lastPlayed:
                            homeViewModel.playlistSongSort = .lastPlayed
                        default:
                            homeViewModel.playlistSongSort = .mostPlayed
                        }
                        let setSongs = await viewModel.setPlaylistSongs(songs: songService.ogSongs)
                        if setSongs {
                            playlistGenViewModel.activePlaylist = playlist
                        }
                        if let limitSortType = playlist.limitSortType {
                            viewModel.assignSortTitles(sortType: LimitSortType(rawValue: limitSortType) ?? LimitSortType.artist)
                        }
                        
                        if let coverData = playlist.cover {
                            playlistGenViewModel.coverData = coverData
                            if let uiImage = UIImage(data: coverData) {
                                coverImage = Image(uiImage: uiImage)
                            }
                        }
                        if let playlistFilters = playlist.filters {
                            let matchingFilters = filtersQuery.filter {
                                playlistFilters.contains($0.id.uuidString)
                            }
                            playlistGenViewModel.assignViewModelValues(playlist: playlist, filters: matchingFilters)
                            if playlist.liveUpdating {
                                let updatedSongs = await playlistGenViewModel.fetchMatchingSongIDs(songs: songService.sortedSongs, filters: matchingFilters, matchRules: playlist.matchRules, limit: playlist.limit, limitType: playlist.limitType, limitSortType: playlist.limitSortType)
                                if updatedSongs != playlist.songs && !updatedSongs.isEmpty {
                                    playlist.songs = updatedSongs
                                    if let matchingPlaylist = songService.userAppleMusicPlaylists.first(where: {$0.url?.absoluteString == playlist.urlString}) {
                                        let lib = MusicLibrary.shared
                                        let songs = songService.ogSongs.filter {
                                            playlist.songs.contains($0.id.rawValue)
                                        }
                                        viewModel.playlistSongs = songs
                                        try await lib.edit(matchingPlaylist, name: playlist.name, items: songs)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                Menu {
                    Button {
                        Task { @MainActor in
                            if let playlistURL {
                                openURL(playlistURL)
                            } else {
                                playlistGenViewModel.createAppleMusicPlaylist(using: playlist, songs: songService.ogSongs)
                                showAlert = true
                            }
                        }
                    } label: {
                        let text = playlist.urlString == nil ? "Add To" : "View In"
                        let icon = playlist.urlString == nil ? "folder.fill.badge.plus" : "eyes"
                        Label("\(text) Apple Music", systemImage: icon)
                    }
                } label: {
                    Image(.appleMusic)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 33, height: 33)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.white)
                                .shadow(radius: 2)
                        )
                }
                
                Menu {
                    Button {
                        self.deletePlaylist()
                    } label: {
                        Label("Delete Playlist", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title.bold())
                        .contentShape(Rectangle())
                        .frame(height: 55)
                        .foregroundStyle(.oreo)
                }
            }
            
            RoundedRectangle(cornerRadius: 1)
                .frame(height: 1)
                .padding(.leading, UIScreen.main.bounds.width / 8)
                .foregroundStyle(.secondary.opacity(0.2))
        }
        .frame(maxWidth: .infinity)
        .task {
            if let coverData = playlist.cover {
                if let uiImage = UIImage(data: coverData) {
                    coverImage = Image(uiImage: uiImage)
                }
            }
        }
        .onChange(of: playlistas.map {$0.cover}) { _, _ in
            if let cover = playlist.cover, let uiImage = UIImage(data: cover) {
                coverImage = Image(uiImage: uiImage)
            }
        }
        .alert("Playlist added to Apple Music!", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
            Button("View") {
                if let playlistURL {
                    openURL(playlistURL)
                }
            }
        }
    }
    
    private var playlistCoverIcon: some View {
        ZStack {
            if let coverImage {
                coverImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.white)
                            .shadow(radius: 2)
                    )
            } else if let song, let artwork = song.artwork {
                ArtworkImage(artwork, width: 44, height: 44)
                    .clipShape(.rect(cornerRadius: 12, style: .continuous))
                    .shadow(radius: 2)
            } else {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .foregroundStyle(.gray.opacity(0.8))
                    .frame(width: 44, height: 44)
            }
        }
    }
    
    private func deletePlaylist() {
        modelContext.delete(playlist)
    }
}
