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
            ZStack(alignment: .bottom) {
                Color.white.ignoresSafeArea()
                
                if let art = viewModel.cancion?.artwork {
                    PlayerView()
                    
                    SongList()
                    
                    PlaylistList()
                    
                    tabs(UIScreen.main.bounds.size, artwork: art)
                        .offset(x: !viewModel.isPlaying ? viewModel.moveSet : .zero)
                        .opacity(viewModel.generatorActive ? 0 : 1)
                } else {
                    ProgressView()
                }
            }
            .onChange(of: viewModel.progress) { oldValue, newValue in
                if newValue >= 0.99000000 && !viewModel.changing {
                    viewModel.handleAutoQueue()
                }
            }
            .onChange(of: viewModel.player.queue.currentEntry) { oldValue, newValue in
                guard oldValue != nil else { return }
//                viewModel.progress = .zero
                if !viewModel.blockExternalChange {
                    viewModel.handleAutoQueue()
                }
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
                        viewModel.blockExternalChange = true
                        try await viewModel.handleForwardPress(songs: viewModel.songService.randomSongs)
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
        .sensoryFeedback(.selection, trigger: viewModel.nextIndex)
        .sensoryFeedback(.selection, trigger: viewModel.isPlaying)
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
