//
//  EditPlaylistView.swift
//  Cancion
//
//  Created by Desmond Fitch on 3/11/24.
//

import SwiftUI
import MusicKit
import SwiftData
import PhotosUI

struct EditPlaylistView: View {
    @Environment(SongService.self) var songService
    @Environment(PlaylistGeneratorViewModel.self) var viewModel
    @Environment(HomeViewModel.self) var homeViewModel
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Query var playlistas: [Playlista]
    @State private var playlistName = ""
    @State private var item: PhotosPickerItem?
    
    var image: Image? {
        if let coverData = viewModel.coverData, let uiiImage = UIImage(data: coverData) {
            return Image(uiImage: uiiImage)
        }
        return nil
    }
    
    var playlist: Playlista
    
    var body: some View {
        ZStack {
            VStack {
                headerTitle
                    .fontDesign(.rounded)
                    .padding(.horizontal, 24)
                ScrollView {
                    VStack {
                        coverPicker
                            .padding(.top, 16)
                        playlistTitle
                            .padding(.top, 24)
                        
                            VStack(alignment: .leading) {
                                smartFilters
                                LimitToStack()
                                divider
                                FilterCheckbox(title: "Live updating", icon: nil, cornerRadius: 12, strokeColor: .oreo, type: .liveUpdating)
                                
                                if viewModel.dropdownActive {
                                    Rectangle()
                                        .fill(.clear.opacity(0.1))
                                        .frame(height: 200)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top)
                    }
                }
                .scrollIndicators(.never)
                .safeAreaPadding(.bottom, 24)
                .scrollDismissesKeyboard(.interactively)
            }
            .padding(.top)
        }
        .task {
            viewModel.assignViewModelValues(playlist: playlist)
            if let coverData = playlist.cover {
                viewModel.coverData = coverData
            }
        }
    }
    
    private var coverPicker: some View {
        VStack {
            PhotosPicker(selection: $item) {
                if let image {
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
                        .overlay {
                            HStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(.naranja.opacity(0.9))
                                        .shadow(radius: 5)
                                        .frame(width: 66)
                                    Image(systemName: "photo.fill")
                                        .font(.title2.bold())
                                }
                                ZStack {
                                    Circle()
                                        .fill(.naranja.opacity(0.9))
                                        .shadow(radius: 5)
                                        .frame(width: 66)
                                    Image(systemName: "trash.fill")
                                        .font(.title2.bold())
                                }
                                .onTapGesture {
                                    viewModel.coverData = nil
                                    item = nil
                                }
                            }
                        }
                        .padding(.horizontal)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.oreo.opacity(0.1))
                            .frame(height: 200)
                        ZStack {
                            Circle()
                                .fill(.naranja.opacity(0.7))
                                .shadow(radius: 5)
                                .frame(width: 66)
                            Image(systemName: "camera.fill")
                                .font(.title2.bold())
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.horizontal, 24)
        .onChange(of: item) { oldValue, newValue in
            Task {
                if let loaded = try? await item?.loadTransferable(type: Data.self) {
                    viewModel.coverData = loaded
                } else {
                    print("Failed")
                }
            }
        }
        .onChange(of: playlistName) { _, newName in
            viewModel.playlistName = newName
        }
    }
    
    private var smartFilters: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                FilterCheckbox(title: "Match", icon: nil, cornerRadius: 12, strokeColor: .oreo, type: .match)
                Dropdown(options: ["all", "any"], selection: "any", type: .matchRules)
                    .frame(width: 66, height: 33)
                Text("of the following rules")
                    .foregroundStyle(.oreo)
                    .fontWeight(.semibold)
                    .font(.title3)
                    .lineLimit(2)
            }
            .zIndex(1000)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.filters.indices, id: \.self) { index in
                    SmartFilterStack(filter: viewModel.filters[index])
                        .disabled(!(viewModel.smartRulesActive))
                        .zIndex(Double(100 - index))
                        .environment(viewModel)
                }
                .blur(radius: !(viewModel.smartRulesActive) ? 2 : 0)
                
                RoundedRectangle(cornerRadius: 1)
                    .frame(height: 1)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .foregroundStyle(.secondary.opacity(0.2))
            }
        }
        .zIndex(10)
    }
    
    private var headerTitle: some View {
        HStack {
            Button {
                withAnimation(.bouncy(duration: 0.4)) {
                    Task {
                        await viewModel.resetViewModelValues()
                    }
                    dismiss()
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
            
            Text("Edit Playlist")
                .foregroundStyle(.oreo)
                .font(.title2.bold())
            
            Spacer()
            
            Button {
                withAnimation(.bouncy(duration: 0.4)) {
                    handleEditPlaylist()
                    dismiss()
                    homeViewModel.generatorActive = false
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.oreo)
                        .frame(width: 44)
                        .shadow(radius: 2)
                    Image(systemName: "checkmark")
                        .foregroundStyle(.naranja)
                        .font(.headline)
                        .fontWeight(.heavy)
                }
            }
        }
    }
    
    private func handleEditPlaylist() {
        Task { @MainActor in
            let songIDs = await viewModel.fetchMatchingSongIDs(songs: homeViewModel.songService.sortedSongs, filters: viewModel.filters, matchRules: viewModel.matchRules, limitType: viewModel.limitType)
            if !songIDs.isEmpty && songIDs != playlist.songs {
                playlist.songs = songIDs
                homeViewModel.songService.playlistSongs = Array(homeViewModel.songService.searchResultSongs).filter {
                    songIDs.contains($0.id.rawValue)
                }
            }
            if viewModel.playlistName != playlist.name && !viewModel.playlistName.isEmpty {
                playlist.name = viewModel.playlistName
            }
            if let cover = viewModel.coverData {
                playlist.cover = cover
            }
            if viewModel.limit != playlist.limit {
                playlist.limit = viewModel.limit
            }
            if viewModel.limitType != playlist.limitType {
                playlist.limitType = viewModel.limitType
            }
            if viewModel.limitSortType != playlist.limitSortType {
                playlist.limitSortType = viewModel.limitSortType
                if let limitSortType = playlist.limitSortType {
                    switch LimitSortType(rawValue: limitSortType) {
                    case .artist:
                        homeViewModel.playlistSongSort = .artist
                    case .mostPlayed:
                        homeViewModel.playlistSongSort = .plays
                    case .lastPlayed:
                        homeViewModel.playlistSongSort = .lastPlayed
                    case .mostRecentlyAdded:
                        homeViewModel.playlistSongSort = .dateAdded
                    case .title:
                        homeViewModel.playlistSongSort = .title
                    default:
                        homeViewModel.playlistSongSort = .plays
                    }
                }
            }
            viewModel.resetViewModelValues()
        }
        dismiss()
        homeViewModel.generatorActive = false
    }
    
    @MainActor
    private func addPlaylistToDatabase(playlist: Playlista) async -> Bool {
        modelContext.insert(playlist)
        return true
    }
    
    private var playlistTitle: some View {
        VStack(alignment: .center, spacing: 8) {
            TextField(playlist.name, text: $playlistName)
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
}
