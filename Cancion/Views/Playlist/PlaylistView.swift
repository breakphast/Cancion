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
    @State var viewModel = PlaylistViewModel()
    @Environment(PlaylistGeneratorViewModel.self) var playlistGeneratorViewModel
    @Environment(\.dismiss) var dismiss
    @State private var text: String = ""
    @Binding var showView: Bool
    @State private var scrollID: String?
    var playCountAscending = false
    @Environment(\.modelContext) var modelContext
    
    var playlist: Playlista
    var songs: [Song]? {
        let sortedSongs = homeViewModel.songService.sortedSongs
        return sortedSongs.filter { playlist.songs.contains($0.id.rawValue) }
    }
    @State var sortedSongs: [Song]?
    
    var body: some View {
        VStack(spacing: 16) {
            navHeaderItems
            
            ScrollView {
                VStack(alignment: .leading) {
                    songSearchTextField
                    playlistCover
                        .id("cover")
                    headerItems
                    songList
                }
                .padding(.top, 4)
            }
            .scrollIndicators(.never)
            .scrollPosition(id: $scrollID)
            .disabled(viewModel.searchActive)
            .blur(radius: viewModel.searchActive ? 5 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .onAppear {
            scrollID = "cover"
        }
        .task {
            if playlist.liveUpdating {
                let updatedSongs = await playlistGeneratorViewModel.fetchMatchingSongIDs(songs: songService.sortedSongs, filters: playlist.filters, matchRules: .any, limitType: playlist.limitType)
                if updatedSongs != playlist.songs {
                    playlist.songs = updatedSongs
                    do {
                        try modelContext.save()
                        print("Updated playlist songs.")
                    } catch {
                        print("Could not save new songs.")
                    }
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
            
            Text(playlist.title)
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
                Image(systemName: "pencil")
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
            }
        }
        .padding(.top)
        .blur(radius: viewModel.searchActive ? 5 : 0)
    }
    private var songSearchTextField: some View {
        TextField("", text: $text)
            .textFieldStyle(CustomTextFieldStyle(text: $text, placeholder: "Search for song", icon: "magnifyingglass"))
            .autocorrectionDisabled()
            .onChange(of: text) { _, _ in
                viewModel.filterSongsByText(text: text, songs: &songService.sortedSongs, songItems: songService.searchResultSongs, using: songService.sortedSongs)
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
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    private var playlistCover: some View {
        ZStack {
            if let cover = playlist.cover, let uiImage = UIImage(data: cover) {
                let image = Image(uiImage: uiImage)
                
                image
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
            } else if let songID = playlist.songs.first, let songID2 = playlist.songs.last, let song1 = songService.sortedSongs.first(where: { $0.id.rawValue == songID }), let song2 = songService.sortedSongs.first(where: { $0.id.rawValue == songID2 }) {
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
        LazyVStack {
            if let songs {
                let songsArray = !viewModel.playCountAscending ?
                songs.sorted { $0.playCount ?? 0 > $1.playCount ?? 0} :
                songs.sorted { $1.playCount ?? 0 > $0.playCount ?? 0}
                
                ForEach(Array(songsArray.enumerated()), id: \.offset) { index, song in
                    SongListRow(song: song, index: viewModel.playCountAscending ? ((songs.count - 1) - index) : index)
                        .onTapGesture {
                            Task {
                                await homeViewModel.handleSongSelected(song: song)
                            }
                        }
                }
            }
        }
    }
}
