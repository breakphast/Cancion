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
    @State private var moveSet: CGFloat = .zero
    @State private var filterActive = false
    let cancion: Song
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                LinearGradient(colors: [.black, .black.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                Color.white.opacity(0.97)
                    .clipShape(.rect(cornerRadius: 24, style: .continuous))
                    .ignoresSafeArea()
                    .frame(height: geo.size.height / (moveSet.isZero ? 2.5 : 1), alignment: .top)
                    .overlay(filterActive ? .black.opacity(0.1) : .clear)
                    .onTapGesture {
                        filterActive = false
                    }
                
                ZStack {
                    VStack {
                        navHeader(geo.size)
                        VStack {
                            if let artwork = cancion.artwork {
                                albumElement(geo.size)
                                    .padding(.top, geo.size.height * 0.05)
                                VStack {
                                    Text(cancion.title)
                                        .lineLimit(1)
                                        .font(.title.bold())
                                    
                                    Text(cancion.artistName)
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondary)
                                    
                                    favDateCapsule(geo.size)
                                }
                                .foregroundStyle(.white)
                                .padding(.vertical, geo.size.height * 0.03)
                                Spacer()
                                tabs(geo.size, artwork: artwork)
                            }
                        }
                        .offset(x: moveSet, y: 0)
                    }
                    .padding()
                    
                    SongList(filterActive: $filterActive)
                        .offset(x: moveSet + geo.size.width, y: 0)
                        .environment(songService)
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
            }
        }
    }
    private func navHeader(_ size: CGSize) -> some View {
        HStack {
            Text("Now Playing")
                .multilineTextAlignment(.leading)
                .kerning(1.1)
                .offset(x: moveSet, y: 0)
            
            Spacer()
            
            Button {
                songService.searchActive = true
                withAnimation(.bouncy(duration: 0.4)) {
                    self.moveSet = self.moveSet.isZero ? -size.width : .zero
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.oreo.opacity(0.9))
                        .frame(width: 44)
                        .shadow(radius: 5)
                    Image(systemName: moveSet.isZero ? "rectangle.stack.fill" : "chevron.left")
                        .foregroundStyle(.white)
                        .font(.headline)
                        .fontWeight(.heavy)
                }
            }
            .offset(x: moveSet.isZero ? (moveSet) : moveSet + size.width / 4, y: 0)
            .padding(.leading, moveSet.isZero ? .zero : 2)
            .blur(radius: filterActive ? 5 : 0)
        }
        .font(.title.bold())
        .foregroundStyle(.oreo)
        .fontDesign(.rounded)
        .padding(.horizontal)
    }
    private func favDateCapsule(_ size: CGSize) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
            Text("27 Plays")
        }
        .font(.caption)
        .foregroundStyle(.primary)
        .fontWeight(.semibold)
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.oreo)
                .shadow(color: .white.opacity(0.1), radius: 6)
        )
    }
    private func tabs(_ size: CGSize, artwork: Artwork) -> some View {
        HStack {
            Spacer()
            tabIcon(icon: "star.fill", active: true)
            Spacer()
            tabIcon(icon: "play.fill", active: false)
                .onTapGesture {
                    withAnimation(.bouncy) {
                        self.moveSet = self.moveSet.isZero ? -size.width : .zero
                    }
                }
            Spacer()
            tabIcon(icon: "rectangle.stack.fill", active: false)
            Spacer()
        }
        .frame(height: 120)
        .background(
            ArtworkImage(artwork, width: size.width * 0.9, height: 120)
                .aspectRatio(contentMode: .fill) // Fill the background, ensuring it covers the area
                .blur(radius: 2, opaque: false)
                .overlay(.ultraThinMaterial.opacity(0.99)) // Use Color overlay for material effect
                .overlay(.primary.opacity(0.2)) // Additional black overlay for depth
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous)) // Clip to rounded rectangle
                .shadow(radius: 5)
        )
    }
}

struct tabIcon: View {
    let icon: String
    let active: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(active ? Color.white.opacity(0.9) : .oreo.opacity(0.9))
                .shadow(radius: 10)
            Image(systemName: icon)
                .bold()
                .foregroundStyle(active ? .oreo.opacity(0.9) : Color.white)
        }
        .frame(width: 55)
    }
}
//
//#Preview {
//    Home()
//}