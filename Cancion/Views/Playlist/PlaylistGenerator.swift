//
//  PlaylistGenerator.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/20/24.
//

import SwiftUI
import MusicKit
import SwiftData
import PhotosUI

struct PlaylistGenerator: View {
    @Environment(SongService.self) var songService
    @Bindable var viewModel: PlaylistGeneratorViewModel
    @Environment(HomeViewModel.self) var homeViewModel
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Query var playlistas: [Playlista]
    @Query var filters: [Filter]
    @State private var item: PhotosPickerItem?
    @State private var imageData: Data?
    @FocusState var isFocused: Bool
    @State private var showError = false
    @State private var playlistName = ""
    
    var image: Image? {
        if let imageData, let uiiImage = UIImage(data: imageData) {
            return Image(uiImage: uiiImage)
        }
        return nil
    }
    
    var genError: Bool? {
        showError = viewModel.genError != nil
        return viewModel.genError != nil
    }
    
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
            .alert(isPresented: $showError, error: viewModel.genError) { _ in
                Button("OK") {
                    viewModel.genError = nil
                }
            } message: { _ in
                Text("Please try again.")
            }
            .onChange(of: playlistName) { _, newName in
                viewModel.playlistName = newName
            }
        }
        .onChange(of: homeViewModel.currentScreen) { _, _ in
            isFocused = false
        }
        .task {
            viewModel.filterModels.append(Filter())
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
                Dropdown(options: ["all", "any"], selection: viewModel.matchRules ?? "all", type: .matchRules)
                    .frame(width: 66, height: 33)
                Text("of the following rules")
                    .foregroundStyle(.oreo)
                    .fontWeight(.semibold)
                    .font(.title3)
                    .lineLimit(2)
            }
            .zIndex(1000)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.filterModels.indices, id: \.self) { index in
                    SmartFilterStack(filter: viewModel.filterModels[index], filterss: $viewModel.filterModels)
                        .disabled(!viewModel.smartRulesActive)
                        .zIndex(Double(100 - index))
                        .environment(viewModel)
                        .focused($isFocused)
                }
                .blur(radius: !viewModel.smartRulesActive ? 2 : 0)
                
                RoundedRectangle(cornerRadius: 1)
                    .frame(height: 1)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .foregroundStyle(.secondary.opacity(0.2))
            }
        }
        .zIndex(10)
    }
    
    private var playlistCover: some View {
        Image(.ken)
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .frame(maxWidth: .infinity)
            .shadow(radius: 5)
            .padding(.horizontal, 24)
    }
    
    func handleCancelPlaylist() {
        homeViewModel.generatorActive = false
        Task { @MainActor in
            viewModel.resetViewModelValues()
        }
        dismiss()
    }
    
    private var headerTitle: some View {
        HStack {
            Button {
                withAnimation(.bouncy(duration: 0.4)) {
                    handleCancelPlaylist()
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
            
            Text("Playlist Generator")
                .foregroundStyle(.oreo)
                .font(.title2.bold())
            
            Spacer()
            
            Button {
                withAnimation(.bouncy(duration: 0.4)) {
                    addPlaylist()
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
    
    private func addPlaylist() {
        Task { @MainActor in
            let addedSuccess = await addPlaylistToDatabase()
            if addedSuccess {
                homeViewModel.generatorActive = false
                dismiss()
            }
        }
    }
    
    @MainActor
    private func addPlaylistToDatabase() async -> Bool {
        if let model = await viewModel.generatePlaylist(songs: songService.sortedSongs, name: viewModel.playlistName, cover: imageData, filters: viewModel.filterModels) {
            modelContext.insert(model)
            if let playlistFilters = model.filters {
                let matchingFilters = viewModel.filterModels.filter {
                    playlistFilters.contains($0.id.uuidString)
                }
                for filter in matchingFilters {
                    modelContext.insert(filter)
                }
            }
            try? modelContext.save()
            viewModel.filters = []
            
            return true
        }
        showError = true
        return false
    }
    
    private var playlistTitle: some View {
        VStack(alignment: .center, spacing: 8) {
            TextField("Playlist Name", text: $playlistName)
                .foregroundStyle(.oreo)
                .font(.title.bold())
                .lineLimit(1)
                .padding(.horizontal, 24)
                .autocorrectionDisabled()
                .focused($isFocused)
                
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
