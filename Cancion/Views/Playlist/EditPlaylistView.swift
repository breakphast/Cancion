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
    @State private var imageData: Data?
    
    var image: Image? {
        if let cover = playlist.cover, let coverImage = UIImage(data: cover) {
            return Image(uiImage: coverImage)
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
                                LimitToStack(playlist: playlist)
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
                    imageData = loaded
                } else {
                    print("Failed")
                }
            }
        }
    }
    
    private var smartFilters: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                FilterCheckbox(title: "Match", icon: nil, cornerRadius: 12, strokeColor: .oreo, type: .match)
                Dropdown(options: ["all", "any"], selection: "any", type: .matchRules, playlist: playlist)
                    .frame(width: 66, height: 33)
                Text("of the following rules")
                    .foregroundStyle(.oreo)
                    .fontWeight(.semibold)
                    .font(.title3)
                    .lineLimit(2)
            }
            .zIndex(1000)
            
            VStack(alignment: .leading, spacing: 12) {
                if let filters = playlist.filters, let smartRules = playlist.smartRules {
                    ForEach(filters.indices, id: \.self) { index in
                        SmartFilterStack(filter: filters[index], playlist: playlist, editing: true)
                            .disabled(!smartRules)
                            .zIndex(Double(100 - index))
                            .environment(viewModel)
                    }
                    .blur(radius: !smartRules ? 2 : 0)
                }
                
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
                    Task {
                        let songIDs = await viewModel.fetchMatchingSongIDs(songs: homeViewModel.songService.sortedSongs, filters: playlist.filters, matchRules: playlist.matchRules, limitType: playlist.limitType, playlist: playlist)
                        var shouldSave = false
                        if !songIDs.isEmpty {
                            playlist.songs = songIDs
                            shouldSave = true
                        }
                        if playlistName != playlist.title {
                            playlist.title = playlistName
                            shouldSave = true
                        }
                        if shouldSave {
                            do {
                                try modelContext.save()
                                dismiss()
                            } catch {
                                print("Could not save edited playlist.")
                            }
                        }
                    }
                    
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
    
    @MainActor
    private func addPlaylistToDatabase(playlist: Playlista) async -> Bool {
        modelContext.insert(playlist)
        return true
    }
    
    private var playlistTitle: some View {
        VStack(alignment: .center, spacing: 8) {
            TextField(playlist.title, text: $playlistName)
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
