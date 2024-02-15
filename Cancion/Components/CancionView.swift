//
//  CancionView.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/15/24.
//

import SwiftUI
import MusicKit

struct CancionView: View {
    @Environment(SongService.self) var songService
    let cancion: Song
    
    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            
            VStack(spacing: 16) {
                artwork(size, artwork: cancion.artwork!)
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(cancion.title)
                                .lineLimit(1)
                            Image(systemName: "e.square.fill")
                        }
                        .font(.title3.bold())
                        
                        Text(cancion.artistName)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.title3.bold())
                        Text("Since Feb. 2, 2024")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                }
                addButton(size)
            }
        }
        .padding(24)
    }
    
    @ViewBuilder
    private func addButton(_ size: CGSize) -> some View {
        Button {
            songService.searchActive = true
        } label: {
            Text("Add new favorite song")
                .foregroundStyle(.white)
                .font(.headline.bold())
                .kerning(1.0)
        }
        .frame(width: size.width)
        .frame(height: 55)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.pink.opacity(0.8))
        )
        .padding(.top, 40)
    }
    
    private func artwork(_ size: CGSize, artwork: Artwork) -> some View {
        ArtworkImage(cancion.artwork!, width: size.width)
            .aspectRatio(contentMode: .fit)
            .clipShape(.rect(cornerRadius: 8))
            .shadow(color: .black.opacity(0.8), radius: 5, x: 2, y: 2)
            .frame(width: size.width, height: size.height / 2)
    }
    
    func openURL(url: URL) {
        UIApplication.shared.open(url)
    }
}
