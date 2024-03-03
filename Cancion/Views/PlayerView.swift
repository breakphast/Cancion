//
//  PlayerView.swift
//  Cancion
//
//  Created by Desmond Fitch on 3/3/24.
//

import SwiftUI
import MusicKit

struct PlayerView: View {
    @Environment(HomeViewModel.self) var viewModel
    var cancion: Song? {
        return viewModel.cancion
    }
    
    @ObservedObject private var playerState = ApplicationMusicPlayer.shared.state
    private var isPlaying: Bool {
        return (playerState.playbackStatus == .playing)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .black.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ZStack(alignment: .top) {
                backgroundCard
                VStack {
                    navHeader
                    mainSongElement
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder
    private var albumElement: some View {
        VStack(spacing: 40) {
            if let artwork = viewModel.cancion?.artwork {
                ArtworkImage(artwork, width: UIScreen.main.bounds.width * 0.9)
                    .clipShape(.rect(cornerRadius: 24, style: .continuous))
                    .shadow(radius: 5)
            } else {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .frame(width: UIScreen.main.bounds.width * 0.9)
                    .shadow(radius: 5)
            }
        }
    }
    private var navHeader: some View {
        HStack {
            Text("Now Playing")
                .multilineTextAlignment(.leading)
                .kerning(1.1)
                .offset(x: viewModel.moveSet, y: 0)
            
            Spacer()
            
            Button {
                withAnimation(.bouncy(duration: 0.4)) {
                    viewModel.moveSet = viewModel.moveSet.isZero ? -UIScreen.main.bounds.width : .zero
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.oreo)
                        .frame(width: 44)
                        .shadow(radius: 2)
                    Image(systemName: viewModel.moveSet.isZero ? "rectangle.stack.fill" : "chevron.left")
                        .foregroundStyle(.white)
                        .font(.headline)
                        .fontWeight(.heavy)
                }
            }
            .offset(x: viewModel.moveSet.isZero ? (viewModel.moveSet) : viewModel.moveSet + UIScreen.main.bounds.width / 4, y: 0)
            .padding(.leading, viewModel.moveSet.isZero ? .zero : 2)
            .blur(radius: viewModel.filterActive ? 5 : 0)
        }
        .font(.title.bold())
        .foregroundStyle(.oreo)
        .fontDesign(.rounded)
        .padding(.horizontal)
    }
    
    private var backgroundCard: some View {
        Color.white.opacity(0.97)
            .clipShape(.rect(cornerRadius: 24, style: .continuous))
            .ignoresSafeArea()
            .conditionalFrame(isZero: viewModel.moveSet.isZero, height: UIScreen.main.bounds.height / 2.5, alignment: .top)
            .overlay(viewModel.filterActive ? .black.opacity(0.1) : .clear)
            .onTapGesture {
                viewModel.filterActive = false
            }
    }
    private var mainSongElement: some View {
        VStack {
            if let cancion, let _ = cancion.artwork {
                albumElement
                    .padding(.top, UIScreen.main.bounds.height * 0.05)
                VStack {
                    Text(cancion.title)
                        .lineLimit(1)
                        .font(.title.bold())
                    
                    Text(cancion.artistName)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    playsCapsule
                }
                .foregroundStyle(.white)
                .padding(.vertical, UIScreen.main.bounds.height * 0.03)
                .padding(.horizontal, 24)
            }
        }
        .offset(x: viewModel.moveSet, y: 0)
    }
    private var playsCapsule: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
            Text("\(cancion?.playCount ?? 0) Plays")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .fontWeight(.semibold)
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.oreo)
                .shadow(color: .white.opacity(0.1), radius: 3)
        )
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

#Preview {
    PlayerView()
}
