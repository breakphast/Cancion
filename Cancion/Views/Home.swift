//
//  Home.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/16/24.
//

import SwiftUI
import MusicKit

struct Home: View {
    @Environment(SongService.self) var songService
    @Bindable var viewModel = HomeViewModel()
    @State var cancion: Song
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                LinearGradient(colors: [.black, .black.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                backgroundCard(geo.size)
                
                ZStack {
                    VStack {
                        navHeader(geo.size)
                        mainSongElement(geo.size)
                    }
                    .padding()
                    
                    SongList(moveSet: $viewModel.moveSet)
                        .offset(x: viewModel.moveSet + geo.size.width, y: 0)
                        .environment(songService)
                        .environment(viewModel)
                    
                    PlaylistList(moveSet: $viewModel.moveSet)
                }
            }
            .task {
                viewModel.setQueue(cancion: cancion)
            }
            .onChange(of: viewModel.player.queue.currentEntry?.id, { oldValue, newValue in
                if let song = viewModel.customQueueSong {
                    self.cancion = song
                    Task {
                        try await viewModel.player.play()
                        viewModel.secondaryPlaying = true
                    }
                }
            })
            .onChange(of: viewModel.nextIndex) { oldValue, newValue in
                Task {
                    do {
                        try await viewModel.changeCancion(cancion: &cancion, songs: songService.randomSongs)
                        print("Changed. Now:", cancion.title)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            .onChange(of: viewModel.secondaryPlaying) { _, newValue in
                if newValue == true {
                    viewModel.startObservingCurrentTrack(cancion: cancion)
                }
            }
        }
    }
    
    @ViewBuilder
    private func albumElement(_ size: CGSize) -> some View {
        VStack(spacing: 40) {
            if let artwork = cancion.artwork {
                ArtworkImage(artwork, width: size.width * 0.9)
                    .clipShape(.rect(cornerRadius: 24, style: .continuous))
                    .shadow(radius: 5)
            } else {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .frame(width: size.width * 0.9)
                    .shadow(radius: 5)
            }
        }
    }
    private func navHeader(_ size: CGSize) -> some View {
        HStack {
            Text("Now Playing")
                .multilineTextAlignment(.leading)
                .kerning(1.1)
                .offset(x: viewModel.moveSet, y: 0)
            
            Spacer()
            
            Button {
                withAnimation(.bouncy(duration: 0.4)) {
                    viewModel.moveSet = viewModel.moveSet.isZero ? -size.width : .zero
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
            .offset(x: viewModel.moveSet.isZero ? (viewModel.moveSet) : viewModel.moveSet + size.width / 4, y: 0)
            .padding(.leading, viewModel.moveSet.isZero ? .zero : 2)
            .blur(radius: viewModel.filterActive ? 5 : 0)
        }
        .font(.title.bold())
        .foregroundStyle(.oreo)
        .fontDesign(.rounded)
        .padding(.horizontal)
    }
    private func backgroundCard(_ size: CGSize) -> some View {
        Color.white.opacity(0.97)
            .clipShape(.rect(cornerRadius: 24, style: .continuous))
            .ignoresSafeArea()
            .frame(height: size.height / (viewModel.moveSet.isZero ? 2.5 : 1), alignment: .top)
            .overlay(viewModel.filterActive ? .black.opacity(0.1) : .clear)
            .onTapGesture {
                viewModel.filterActive = false
            }
    }
    private func mainSongElement(_ size: CGSize) -> some View {
        VStack {
            if let artwork = cancion.artwork {
                albumElement(size)
                    .padding(.top, size.height * 0.05)
                VStack {
                    Text(cancion.title)
                        .lineLimit(1)
                        .font(.title.bold())
                    
                    Text(cancion.artistName)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    playsCapsule(size)
                }
                .foregroundStyle(.white)
                .padding(.vertical, size.height * 0.03)
                .padding(.horizontal, 24)
                Spacer()
                tabs(size, artwork: artwork)
            }
        }
        .offset(x: viewModel.moveSet, y: 0)
    }
    private func playsCapsule(_ size: CGSize) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
            Text("\(cancion.playCount ?? 0) Plays")
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
            TabIcon(icon: "backward.fill", active: false, progress: $viewModel.progress, isPlaying: viewModel.isPlaying)
                .overlay {
                    Circle()
                        .fill(viewModel.nextIndex <= 0 ? Color.oreo.opacity(0.6) : .clear)
                }
                .disabled(viewModel.nextIndex <= 0)
                .onTapGesture {
                    Task {
                        guard viewModel.nextIndex > 0 else { return }
                        try await viewModel.handleSongChange(forward: false)
                    }
                }
            Spacer()
            TabIcon(icon: viewModel.secondaryPlaying ?  "pause.fill" : "play.fill", active: true, progress: $viewModel.progress, isPlaying: viewModel.secondaryPlaying)
                .onTapGesture {
                    withAnimation(.bouncy) {
                        viewModel.handlePlayButton()
                        viewModel.secondaryPlaying = viewModel.isPlaying ? false : true
                    }
                }
            Spacer()
            TabIcon(icon: "forward.fill", active: false, progress: $viewModel.progress, isPlaying: viewModel.isPlaying)
                .onTapGesture {
                    Task {
                        try await viewModel.handleSongChange(forward: true)
                        try await viewModel.changeCancion(cancion: &cancion, songs: songService.randomSongs)
                    }
                }
            Spacer()
        }
        .frame(height: 120)
        .background(
            ArtworkImage(artwork, width: size.width * 0.9, height: 120)
                .aspectRatio(contentMode: .fill)
                .blur(radius: 2, opaque: false)
                .overlay(.ultraThinMaterial.opacity(0.99))
                .overlay(.primary.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(radius: 2)
        )
        .sensoryFeedback(.selection, trigger: viewModel.nextIndex)
        .sensoryFeedback(.selection, trigger: viewModel.secondaryPlaying)
    }
}
