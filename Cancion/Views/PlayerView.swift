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
    @State private var songDateAdded: String?
    
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
        .task {
            if let date = cancion?.libraryAddedDate {
                songDateAdded = Helpers().dateFormatter.string(from: date)
            }
        }
        .onChange(of: cancion) { oldValue, newValue in
            if let date = cancion?.libraryAddedDate {
                songDateAdded = Helpers().dateFormatter.string(from: date)
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
                withAnimation {
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
        let shape = UnevenRoundedRectangle(cornerRadii: .init(topLeading: 0, bottomLeading: 24, bottomTrailing: 24, topTrailing: 0))
        
        return Color.white.opacity(0.97)
            .clipShape(shape)
            .ignoresSafeArea()
            .frame(height: UIScreen.main.bounds.height / 2.5, alignment: .top)
            .overlay(viewModel.filterActive ? .black.opacity(0.1) : .clear)
            .onTapGesture {
                viewModel.filterActive = false
            }
    }

    private var mainSongElement: some View {
        VStack {
            if let cancion {
                VStack {
                    albumElement
                        .padding(.top, UIScreen.main.bounds.height * 0.05)
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
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
                        }
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 8) {
                            playsCapsule
                            dateAdded
                        }
                    }
                    .padding(.horizontal, (screenWidth > 1000 ? 40 : 16))
                    Rectangle()
                        .fill(.clear)
                        .frame(height: screenHeight < 700 ? 80 : 100)
                    Spacer()
                }
                .foregroundStyle(.white)
            }
        }
    }
    private var playsCapsule: some View {
        HStack(alignment: .center ,spacing: 4) {
            Image(systemName: "memories")
                .font(.title3)
            Text("\(cancion?.playCount ?? 0)")
        }
        .font(.title.bold())
        .foregroundStyle(.white)
        .fontWeight(.semibold)
    }
    
    private var dateAdded: some View {
        HStack(alignment: .center, spacing: 4) {
            Image(systemName: "calendar.badge.plus")
                .font(.title3)
                .offset(y: 1)
            Text(songDateAdded ?? "")
                .kerning(1.1)
        }
        .font(.title2)
        .foregroundStyle(.secondary)
        .fontWeight(.medium)
    }
    private var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    private var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    private var backgroundRect: UnevenRoundedRectangle? {
        if screenHeight < 700 {
            return UnevenRoundedRectangle(cornerRadii: .init(topLeading: 0, bottomLeading: 24, bottomTrailing: 24, topTrailing: 0))
        }
        return nil
    }
}

#Preview {
    PlayerView()
}
