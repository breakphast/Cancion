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
        .offset(x: viewModel.moveSet)
        .gesture(viewModel.swipeGesture)
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
                    viewModel.currentScreen = .songs
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.oreo)
                        .frame(width: 44)
                        .shadow(radius: 2)
                    Image(systemName: "music.note.list")
                        .foregroundStyle(.white)
                        .font(.title3)
                        .fontWeight(.heavy)
                }
            }
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
                    HStack(spacing: 4) {
                        Text(cancion.title)
                            .lineLimit(1)
                            .font(.title.bold())
                        if cancion.contentRating == .explicit {
                            Image(systemName: "e.square.fill")
                                .font(.subheadline)
                                .foregroundStyle(.naranja)
                        }
                    }
                    
                    Text(cancion.artistName)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
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
}

#Preview {
    PlayerView()
}
