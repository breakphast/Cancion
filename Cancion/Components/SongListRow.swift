//
//  SongListRow.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/27/24.
//

import SwiftUI
import MusicKit

struct SongListRow: View {
    @Environment(HomeViewModel.self) var homeViewModel
    let song: Song
    let index: Int
    var songSort: SongSortOption {
        return homeViewModel.songSort
    }
    var body: some View {
        VStack {
            HStack {
                songBadge
                art
                songInfo
                
                Spacer()
                sortInfo
            }
            .frame(height: 55)
            
            CustomDivider()
        }
    }
    
    private var sortInfo: some View {
        ZStack {
            switch songSort {
            case .dateAdded:
                if let dateAdded = song.libraryAddedDate {
                    HStack(spacing: 2) {
                        Text(homeViewModel.dateFormatter.string(from: dateAdded))
                    }
                    .foregroundStyle(.oreo)
                    .font(.caption2)
                    .fontWeight(.black)
                }
            case .plays:
                Text("\(song.playCount ?? 0)")
                    .fontWeight(.bold)
            case .lastPlayed:
                if let lastPlayedDate = song.lastPlayedDate {
                    HStack(spacing: 2) {
                        Text(homeViewModel.dateFormatter.string(from: lastPlayedDate))
                    }
                    .foregroundStyle(.oreo)
                    .font(.caption2)
                    .fontWeight(.black)
                }
            }
        }
    }
    
    private var songBadge: some View {
        ZStack {
            Image(systemName: "seal.fill")
                .font(.title)
                .foregroundStyle(index == 0 ? .naranja : .clear)
            if let plays = song.playCount, plays > 0 {
                Text("\(index + 1)")
                    .fontWeight(.semibold)
                    .foregroundStyle(index == 0 ? .white : .primary)
            } else {
                Text("-")
                    .fontWeight(.semibold)
                    .foregroundStyle(index == 0 ? .white : .primary)
            }
        }
        .lineLimit(1)
        .frame(maxWidth: 44, alignment: .leading)
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
            HStack(spacing: 4) {
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
