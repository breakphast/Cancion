//
//  PlaylistListRow.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/27/24.
//

import SwiftUI
import MusicKit

struct PlaylistListRow: View {
    let playlist: PlaylistModel
    
    var song: Song? {
        if let song = playlist.songs.first {
            return song
        }
        return nil
    }
    
    var body: some View {
        VStack {
            HStack {
                if let song, let artwork = song.artwork {
                    ArtworkImage(artwork, width: 44, height: 44)
                        .clipShape(.rect(cornerRadius: 12, style: .continuous))
                        .shadow(radius: 2)
                } else {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .foregroundStyle(.gray.opacity(0.8))
                        .frame(width: 44, height: 44)
                }
                
                Text(playlist.title)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 4)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "ellipsis")
                    .fontWeight(.bold)
            }
            .frame(height: 55)
            
            RoundedRectangle(cornerRadius: 1)
                .frame(height: 1)
                .padding(.leading, UIScreen.main.bounds.width / 8)
                .foregroundStyle(.secondary.opacity(0.2))
        }
        .frame(maxWidth: .infinity)
    }
}
