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
    var cancion: Song? {
        return viewModel.cancion
    }
    
    @ObservedObject private var playerState = ApplicationMusicPlayer.shared.state
    private var isPlaying: Bool {
        return (playerState.playbackStatus == .playing)
    }
    
    var body: some View {
        GeometryReader { geo in
            if viewModel.isPlaybackQueueSet {
                ZStack(alignment: .bottom) {
                    Color.white.ignoresSafeArea()
                    
                    if let art = viewModel.cancion?.artwork {
                        PlayerView()
                        
                        SongList()
                        
                        PlaylistList()
                        
                        if !viewModel.generatorActive {
                            tabs(UIScreen.main.bounds.size, artwork: art)
                                .offset(x: !viewModel.isPlaying ? viewModel.moveSet : .zero)
                                .opacity(viewModel.isPlaybackQueueSet ? 1 : 0)
                        }
                    } else {
                        ProgressView()
                    }
                }
                .onChange(of: viewModel.player.queue.currentEntry) { oldValue, newValue in
                    guard let oldValue, let newValue else { return }
                    
                    if let previousID = viewModel.previousQueueEntryID {
                        if !viewModel.blockExternalChange || !viewModel.changing {
                            viewModel.handleAutoQueue(forward: previousID != newValue.id ? true : false)
                        } else {
                            viewModel.blockExternalChange = false
                            viewModel.changing = false
                        }
                    } else {
                        if !viewModel.blockExternalChange || !viewModel.changing {
                            viewModel.handleAutoQueue(forward: true)
                        } else {
                            viewModel.blockExternalChange = false
                            viewModel.changing = false
                        }
                    }
                    
                    viewModel.previousQueueEntryID = oldValue.id
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .environment(viewModel)
        .task {
            viewModel.initializeQueue(songs: viewModel.songService.randomSongs)
        }
    }
    private func tabs(_ size: CGSize, artwork: Artwork) -> some View {
        HStack {
            Spacer()
            TabIcon(icon: "backward.fill", progress: viewModel.progress, isPlaying: viewModel.isPlaying)
                .overlay {
                    Circle()
                        .fill(viewModel.nextIndex <= 0 ? Color.oreo.opacity(0.6) : .clear)
                }
                .disabled(viewModel.nextIndex <= 0)
                .onTapGesture {
                    Task {
                        try await viewModel.handleChangePress(songs: viewModel.songService.randomSongs, forward: false)
                    }
                }
            Spacer()
            TabIcon(icon: isPlaying ?  "pause.fill" : "play.fill", playButton: true, progress: viewModel.progress, isPlaying: isPlaying)
                .onTapGesture {
                    withAnimation(.bouncy) {
                        viewModel.handlePlayButtonSelected()
                    }
                }
            Spacer()
            TabIcon(icon: "forward.fill", progress: viewModel.progress, isPlaying: viewModel.isPlaying)
                .onTapGesture {
                    Task {
                        try await viewModel.handleChangePress(songs: viewModel.songService.randomSongs, forward: true)
                    }
                }
            Spacer()
        }
        .frame(height: 120)
        .background(
            ArtworkImage(artwork, width: UIScreen.main.bounds.width * 0.9, height: 120)
                .aspectRatio(contentMode: .fill)
                .blur(radius: 2, opaque: false)
                .overlay(.ultraThinMaterial.opacity(0.99))
                .overlay(viewModel.generatorActive ? .white.opacity(0.2) : .primary.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(radius: 2)
        )
        .sensoryFeedback(.selection, trigger: viewModel.isPlaying)
        .sensoryFeedback(.selection, trigger: viewModel.player.queue.currentEntry?.id)
    }

}

extension View {
    @ViewBuilder func conditionalFrame(isZero: Bool, height: CGFloat, alignment: Alignment) -> some View {
        if isZero {
            self.frame(height: height, alignment: alignment)
        } else {
            self // Do not modify the view if isZero is false
        }
    }
}

extension CGFloat {
    func formatToThreeDecimals() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 3
        formatter.maximumFractionDigits = 3
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
