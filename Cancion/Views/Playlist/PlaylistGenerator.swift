//
//  PlaylistGenerator.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/20/24.
//

import SwiftUI
import MusicKit
import SwiftData

struct PlaylistGenerator: View {
    @Environment(SongService.self) var songService
    @Bindable var viewModel: PlaylistGeneratorViewModel
    @Environment(HomeViewModel.self) var homeViewModel
    @Environment(\.modelContext) var modelContext
    @Query var playlistas: [Playlista]
    
    var body: some View {
        ZStack {
            VStack {
                headerTitle
                    .fontDesign(.rounded)
                    .padding(.horizontal, 24)
                ScrollView {
                    VStack {
                        playlistCover
                            .padding(.top, 16)
                        playlistTitle
                            .padding(.top, 24)
                        
                            VStack(alignment: .leading) {
                                smartFilters
                                LimitToStack(filter: songService.limitFilter)
                                divider
                                FilterCheckbox(title: "Live updating", icon: nil, cornerRadius: 12, strokeColor: .oreo, smartRules: $viewModel.smartRulesActive)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top)
                    }
                }
                .scrollIndicators(.never)
                .safeAreaPadding(.bottom, 24 + viewModel.keyboardHeight)
                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    viewModel.trackKeyboardHeight()
                }
            }
            .padding(.top)
        }
    }
    
    private var smartFilters: some View {
        VStack(alignment: .leading, spacing: 24) {
            FilterCheckbox(title: "Smart Rules", icon: "questionmark.circle.fill", cornerRadius: 12, strokeColor: .oreo, smartRules: $viewModel.smartRulesActive)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.activeFilters.indices, id: \.self) { index in
                    SmartFilterStack(filter: viewModel.activeFilters[index])
                        .disabled(!viewModel.smartRulesActive)
                        .zIndex(Double(100 - index))
                        .environment(viewModel)
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
        homeViewModel.moveSet += UIScreen.main.bounds.width
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
                    homeViewModel.moveSet += UIScreen.main.bounds.width
                    Task {
                        await addPlaylistToDatabase()
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
    private func addPlaylistToDatabase() async -> Bool {
        if let model = await viewModel.generatePlaylist(songs: songService.sortedSongs) {
            modelContext.insert(model)
            viewModel.activeFilters = [FilterModel()]
            return true
        }
        return false
    }
    
    private var playlistTitle: some View {
        VStack(alignment: .center, spacing: 8) {
            TextField("Playlist Name", text: $viewModel.playlistName)
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

#Preview {
    PlaylistGenerator(viewModel: PlaylistGeneratorViewModel())
        .environment(SongService())
        .environment(HomeViewModel())
}

