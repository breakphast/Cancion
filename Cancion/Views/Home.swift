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
                
                ZStack {
                    VStack {
                        navHeader(geo.size)
                        VStack {
                            if let artwork = cancion.artwork {
                                albumElement(geo.size)
                                    .padding(.vertical, geo.size.height * 0.05)
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
//                                .padding(.bottom, geo.size.height * 0.01)
                                Spacer()
                                tabs(geo.size, artwork: artwork)
                            }
                        }
                        .offset(x: moveSet, y: 0)
                    }
                    .padding([.horizontal, .bottom])
                    
                    SearchView()
                        .offset(x: moveSet + geo.size.width, y: 0)
                }
            }
        }
    }
    
    @ViewBuilder
    private func albumElement(_ size: CGSize) -> some View {
        VStack(spacing: 40) {
            ZStack(alignment: .bottomTrailing) {
                if let artwork = cancion.artwork {
                    ArtworkImage(artwork, width: size.width * 0.9)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
                        .clipShape(.rect(cornerRadius: 24, style: .continuous))
                        .shadow(radius: 5)
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.white)
                        .background(Circle().fill(.oreo))
                        .padding(8)
                        .shadow(radius: 2)
                }
            }
        }
        .foregroundStyle(.white)
        .fontDesign(.rounded)
    }
    private func navHeader(_ size: CGSize) -> some View {
        HStack {
            Text("Hello, Desmond")
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
                        .fill(.oreo)
                        .frame(width: 44)
                        .shadow(radius: 5)
                    Image(systemName: "plus")
                        .foregroundStyle(.white)
                        .font(.title3)
                        .fontWeight(.heavy)
                }
            }
            .offset(x: moveSet.isZero ? (moveSet) : moveSet + size.width / 4, y: 0)
        }
        .font(.title.bold())
        .foregroundStyle(.oreo)
        .fontDesign(.rounded)
        .padding(.horizontal)
    }
    private func tabs(_ size: CGSize, artwork: Artwork) -> some View {
        HStack {
            Spacer()
            tabIcon(icon: "star.fill", active: true)
            Spacer()
            tabIcon(icon: "play.fill", active: false)
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
    private func favDateCapsule(_ size: CGSize) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
            Text("Feb. 18, 2024")
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
        .padding(.vertical)
    }
    private func moreSongsElement(_ size: CGSize) -> some View {
        HStack(spacing: 16) {
            [Image(.uzi), Image(.uzi)].randomElement()!
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(.rect(cornerRadius: 8, style: .continuous))
                .frame(width: 44)
                .shadow(color: .white.opacity(0.2), radius: 5)
            VStack(alignment: .leading) {
                Text("Leh Go")
                    .bold()
                Text("Osamason")
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("3:12")
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
        .foregroundStyle(.white)
        .fontDesign(.rounded)
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
