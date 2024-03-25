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
    @State var playlist: Playlista
    @Environment(SongService.self) var songService
    @Environment(PlaylistGeneratorViewModel.self) var playlistViewModel
    @Environment(HomeViewModel.self) var homeViewModel
    @Environment(\.modelContext) var modelContext
    @State private var showMenu = false
    
    var song: Song? {
        if let songID = playlist.songs.first, let song = Array(homeViewModel.songService.ogSongs).first(where: {$0.id.rawValue == songID}) {
            return song
        }
        return nil
    }
    
    var name: String {
        return playlist.name
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
                    Task {
                        let setSongs = await setPlaylistSongs()
                        if setSongs {
                            playlistViewModel.setActivePlaylist(playlist: playlist)
                        }
                    }
                }
                
                Spacer()
                
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
                }
            }
            
            RoundedRectangle(cornerRadius: 1)
                .frame(height: 1)
                .padding(.leading, UIScreen.main.bounds.width / 8)
                .foregroundStyle(.secondary.opacity(0.2))
        }
        .frame(maxWidth: .infinity)
    }
    
    private func setPlaylistSongs() async -> Bool {
        homeViewModel.songService.playlistSongs = Array(homeViewModel.songService.ogSongs).filter {
            playlist.songs.contains($0.id.rawValue)
            }
        homeViewModel.songService.ogPlaylistSongs = Array(homeViewModel.songService.ogSongs).filter {
            playlist.songs.contains($0.id.rawValue)
            }
        if let limitSortType = playlist.limitSortType, let sortOption = LimitSortType(rawValue: limitSortType) {
            homeViewModel.playlistSongSort = sortOption
        }
        return !homeViewModel.songService.playlistSongs.isEmpty
    }
    
    private var playlistCoverIcon: some View {
        ZStack {
            if let cover = playlist.cover, let uiImage = UIImage(data: cover) {
                let image = Image(uiImage: uiImage)
                
                image
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
