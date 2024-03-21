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
    var playlistSongSort: PlaylistSongSortOption? {
        return homeViewModel.playlistSongSort
    }
    var body: some View {
        VStack {
            HStack {
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
        let (info, format) = sortInfoDetails()
        
        return Group {
            if let info = info {
                switch format {
                case .date:
                    InfoText(info)
                case .count:
                    Text(info).fontWeight(.bold)
                }
            }
        }
    }
    
    private func InfoText(_ text: String) -> some View {
        HStack(spacing: 2) {
            Text(text)
        }
        .foregroundStyle(.oreo)
        .font(.caption2)
        .fontWeight(.black)
    }
    
    private func sortInfoDetails() -> (info: String?, format: TextFormat) {
        if let playlistSort = playlistSongSort {
            switch playlistSort {
            case .dateAdded, .lastPlayed:
                let date = (playlistSort == .dateAdded) ? song.libraryAddedDate : song.lastPlayedDate
                return (homeViewModel.dateFormatter.string(from: date ?? Date()), .date)
            case .plays:
                return ("\(song.playCount ?? 0)", .count)
            default:
                return ("\(song.playCount ?? 0)", .count)
            }
        } else {
            switch songSort {
            case .dateAdded, .lastPlayed:
                let date = (songSort == .dateAdded) ? song.libraryAddedDate : song.lastPlayedDate
                return (homeViewModel.dateFormatter.string(from: date ?? Date()), .date)
            case .plays:
                return ("\(song.playCount ?? 0)", .count)
            }
        }
    }

    enum TextFormat {
        case date, count
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
