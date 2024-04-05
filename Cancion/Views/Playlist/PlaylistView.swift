//
//  PlaylistView.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/27/24.
//

import SwiftUI
import MusicKit
import SwiftData

struct PlaylistView: View {
    @Environment(SongService.self) var songService
    @Environment(HomeViewModel.self) var homeViewModel
    @Environment(PlaylistGeneratorViewModel.self) var playlistGeneratorViewModel
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Query var filtersQuery: [Filter]
    
    @Environment(PlaylistViewModel.self) var viewModel
    @State private var text: String = ""
    var playCountAscending = false
    
    @FocusState var isFocused: Bool
    @Binding var showView: Bool
    @Binding var activePlaylist: Playlista?
    @State private var showGenerator = false
    @State private var scrollID: String?
    
    var playlist: Playlista
    var songs: [Song] {
        let playlistSongs = viewModel.playlistSongs
        return text.isEmpty ? playlistSongs : playlistSongs.filter { $0.title.contains(text) || $0.artistName.contains(text) }
    }
    var coverImage: Image? {
        if let cover = playlistGeneratorViewModel.coverData {
            if let uiImage = UIImage(data: cover) {
                return Image(uiImage: uiImage)
            }
        }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 16) {
            navHeaderItems
                .padding(.horizontal, 24)
            
            ScrollView {
                VStack(alignment: .center) {
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
        }
        .onChange(of: homeViewModel.currentScreen) { _, _ in
            isFocused = false
        }
        .onChange(of: playlist.cover ?? Data(), { _, newCover in
            playlistGeneratorViewModel.coverData = newCover
        })
        .onAppear {
            scrollID = "cover"
        }
        .onChange(of: viewModel.songSort, { _, songSort in
            viewModel.assignSortTitles(sortType: songSort)
        })
        .onChange(of: songService.playlistSongs) { _, newSongs in
            viewModel.playlistSongs = newSongs
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
                        await viewModel.resetPlaylistViewModelValues()
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
            .onChange(of: text) { _, _ in
                text = text
                viewModel.filterSongsByText(text: text, songs: &songService.playlistSongs, using: songService.ogPlaylistSongs)
            }
    }
    private var headerItems: some View {
        HStack {
            Spacer()
            
            Button {
                viewModel.playCountAscending.toggle()
                
            } label: {
                HStack(spacing: 4) {
                    Text(viewModel.sortTitle)
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
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 200)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.white)
                            .shadow(radius: 3)
                    )
                    .padding()
            } else if let songID = playlist.songs.first, let songID2 = playlist.songs.last, let song1 = Array(songService.ogSongs).first(where: { $0.id.rawValue == songID }), let song2 = Array(songService.ogSongs).first(where: { $0.id.rawValue == songID2 }) {
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
                SongListRow(song: song, index: viewModel.playCountAscending ? ((viewModel.playlistSongs.count - 1) - index) : index)
                    .onTapGesture {
                        Task {
                            let upperBound = index + 50 > viewModel.playlistSongs.count ? viewModel.playlistSongs.count : index + 20
                            let _ = await homeViewModel.handleSongSelected(song: song, songs: Array(viewModel.playlistSongs[index..<upperBound]))
                        }
                    }
            }
        }
    }
}
