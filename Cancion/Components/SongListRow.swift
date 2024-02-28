//
//  SongListRow.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/27/24.
//

import SwiftUI
import MusicKit

struct SongListRow: View {
    let song: Song
    let index: Int
    
    var body: some View {
        VStack {
            HStack {
                songBadge
                art
                songInfo
                
                Spacer()
                
                Text("\(song.playCount ?? 0)")
                    .fontWeight(.bold)
            }
            .frame(height: 55)
            
            CustomDivider()
        }
    }
    private var songBadge: some View {
        ZStack {
            Image(systemName: "seal.fill")
                .font(.title)
                .foregroundStyle(index == 0 ? .naranja : .clear)
            Text("\(index + 1)")
                .fontWeight(.semibold)
                .foregroundStyle(index == 0 ? .white : .primary)
        }
        .padding(.trailing, 8)
    }
    private var art: some View {
        ZStack {
            if let artwork = song.artwork {
                ArtworkImage(artwork, width: 44)
                    .clipShape(.rect(cornerRadius: 22, style: .continuous))
                    .shadow(radius: 2)
            } else {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .foregroundStyle(.gray.opacity(0.8))
                    .frame(width: 44, height: 44)
            }
        }
    }
    
    private var songInfo: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(song.title)
                    .fontWeight(.semibold)
                Image(systemName: "e.square.fill").opacity(song.contentRating == .explicit ? 1 : 0)
                    .font(.caption)
                    .foregroundStyle(.oreo)
            }
            Text(song.artistName)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 4)
        .lineLimit(1)
    }
}
