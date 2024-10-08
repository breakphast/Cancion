//
//  Home.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/16/24.
//

import SwiftUI
import MusicKit

struct Home: View {
    @Environment(HomeViewModel.self) var viewModel
    @Environment(SongService.self) var songService
    @ObservedObject private var playerState = ApplicationMusicPlayer.shared.state
    private var isPlaying: Bool {
        return (playerState.playbackStatus == .playing)
    }
    private var cancion: Song? {
        return viewModel.cancion
    }
    @State private var emptyLibrary = false
    
    var body: some View {
        GeometryReader { geo in
            if viewModel.isPlaybackQueueSet {
                ZStack(alignment: .bottom) {
                    Color.white.opacity(0.97).ignoresSafeArea()
                    if !viewModel.ogSongs.isEmpty {
                        PlayerView()
                        
                        SongList()
                        
                        PlaylistList()
                        
                        tabs(UIScreen.main.bounds.size)
                            .padding(.horizontal)
                            .offset(x: !viewModel.isPlaying ? viewModel.moveSet : .zero)
                            .opacity(!viewModel.generatorActive ? 1 : 0)
                            .overlay {
                                backToPlayerButton
                            }
                    } else {
                        ProgressView()
                    }
                }
                .onChange(of: viewModel.player.queue.currentEntry) { oldValue, newSong in
                    viewModel.handleQueueChange(old: oldValue, new: newSong)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .task {
                        do {
                            try await viewModel.handleSongsInit(songService: songService)
                        } catch {
                            
                        }
                    }
                    .alert(isPresented: $emptyLibrary, error: GenErrors.emptySongsInit) { _ in
                        Button("OK") {
                            
                        }
                        .disabled(emptyLibrary)
                    } message: { _ in
                        Text("Please reset and try again.")
                    }
                    .onChange(of: songService.emptyLibrary) { oldValue, newValue in
                        emptyLibrary = newValue
                    }
            }
        }
        .environment(viewModel)
    }
    
    private func tabs(_ size: CGSize) -> some View {
        HStack {
            Spacer()
            TabIcon(icon: "backward.fill", progress: viewModel.progress, isPlaying: viewModel.isPlaying)
                .overlay {
                    Circle()
                        .fill(!viewModel.queueActive ? Color.oreo.opacity(0.6) : .clear)
                }
                .disabled(!viewModel.queueActive)
                .onTapGesture {
                    Task {
                        try await viewModel.handleChangePress(forward: false)
                    }
                }
            Spacer()
            TabIcon(icon: isPlaying ?  "pause.fill" : "play.fill", playButton: true, progress: viewModel.progress, isPlaying: isPlaying)
                .onTapGesture {
                    withAnimation {
                        viewModel.handlePlayButtonSelected()
                    }
                }
            Spacer()
            TabIcon(icon: "forward.fill", progress: viewModel.progress, isPlaying: viewModel.isPlaying)
                .onTapGesture {
                    Task {
                        try await viewModel.handleChangePress(forward: true)
                    }
                }
            Spacer()
        }
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(radius: 2)
        )
        .sensoryFeedback(.selection, trigger: viewModel.isPlaying)
        .sensoryFeedback(.selection, trigger: viewModel.player.queue.currentEntry?.id)
    }
    private var backToPlayerButton: some View {
        Button {
            
        } label: {
            Button {
                withAnimation {
                    viewModel.currentScreen = .player
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.oreo.opacity(0.8))
                        .frame(width: 44)
                        .shadow(radius: 2)
                    Image(systemName: "waveform.circle.fill")
                        .foregroundStyle(.white)
                        .font(.title3)
                        .fontWeight(.heavy)
                }
            }
        }
        .offset(y: -92)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 32)
        .opacity(!viewModel.isPlaying ? 0 : viewModel.currentScreen == .playlists ? 1 : 0)
    }
}
