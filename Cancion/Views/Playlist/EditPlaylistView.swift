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
    @Environment(HomeViewModel.self) var homeViewModel
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Query var playlistas: [Playlista]
    @State var filterrs: [FilterModel] = []
    
    @Bindable var editPlaylistViewModel = EditPlaylistViewModel()
    
    var genError: Bool? {
        editPlaylistViewModel.showError = editPlaylistViewModel.genError != nil
        return editPlaylistViewModel.genError != nil
    }
    
    var image: Image? {
        if let coverData = editPlaylistViewModel.coverData, let uiiImage = UIImage(data: coverData) {
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
                                
                                if editPlaylistViewModel.dropdownActive {
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
            .alert(isPresented: $editPlaylistViewModel.showError, error: editPlaylistViewModel.genError) { _ in
                Button("OK") {
                    editPlaylistViewModel.genError = nil
                }
            } message: { _ in
                Text("Please try again.")
            }
        }
        .task {
            if let coverData = playlist.cover {
                editPlaylistViewModel.coverData = coverData
                if let uiImage = UIImage(data: coverData) {
                    editPlaylistViewModel.coverImage = Image(uiImage: uiImage)
                }
            }
            if let filters = playlist.filters {
                let filterIDS = filters.map({$0.id.uuidString})
                let matchingFilters = filters.filter {
                    filterIDS.contains($0.id.uuidString)
                }
                self.filterrs = matchingFilters
            }
        }
    }
    
    private var coverPicker: some View {
        VStack {
            PhotosPicker(selection: $editPlaylistViewModel.item) {
                if let coverImage = editPlaylistViewModel.coverImage {
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
                                    editPlaylistViewModel.coverData = nil
                                    editPlaylistViewModel.item = nil
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
        .onChange(of: editPlaylistViewModel.item) { oldValue, newValue in
            Task { @MainActor in
                if let loaded = try? await editPlaylistViewModel.item?.loadTransferable(type: Data.self) {
                    editPlaylistViewModel.coverData = loaded
                    if let uiImage = UIImage(data: loaded) {
                        editPlaylistViewModel.coverImage = Image(uiImage: uiImage)
                    }
                } else {
                    print("Failed")
                }
            }
        }
        .onChange(of: editPlaylistViewModel.playlistName) { _, newName in
            print(newName)
            editPlaylistViewModel.playlistName = newName
        }
    }
    
    private var smartFilters: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                FilterCheckbox(title: "Match", icon: nil, cornerRadius: 12, strokeColor: .oreo, type: .match)
                Dropdown(options: ["all", "any"], selection: playlist.matchRules ?? "all", type: .matchRules)
                    .frame(width: 66, height: 33)
                Text("of the following rules")
                    .foregroundStyle(.oreo)
                    .fontWeight(.semibold)
                    .font(.title3)
                    .lineLimit(2)
            }
            .zIndex(1000)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(filterrs, id: \.id) { filter in
                    if let index = filterrs.firstIndex(where: {$0.id == filter.id}) {
                        SmartFilterStack(filter: filter, filterss: $filterrs)
                            .disabled(!(editPlaylistViewModel.smartRulesActive))
                            .zIndex(Double(100 - index))
                    } else {
                        Text("NOpe")
                    }
                }
                .blur(radius: !(editPlaylistViewModel.smartRulesActive) ? 2 : 0)
                
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
                        await editPlaylistViewModel.resetViewModelValues()
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
                Task { @MainActor in
                    if await editPlaylistViewModel.handleEditPlaylist(songService: songService, playlist: playlist, filters: filterrs) {
                        dismiss()
                        editPlaylistViewModel.resetViewModelValues()
                        homeViewModel.generatorActive = false
                        do {
                            try modelContext.save()
                        } catch {
                            print("Failed to save.")
                        }
                    }
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
    
    private var playlistTitle: some View {
        VStack(alignment: .center, spacing: 8) {
            TextField(playlist.name, text: $editPlaylistViewModel.playlistName)
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
