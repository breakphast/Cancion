//
//  SongList.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/19/24.
//

import SwiftUI
import MusicKit

struct SongList: View {
    @Environment(SongService.self) var songService
    @Environment(SongListViewModel.self) var viewModel
    @State private var text: String = ""
    @Binding var moveSet: CGFloat
    
    var body: some View {
        VStack {
            navHeaderItems
            
            ScrollView {
                VStack(alignment: .leading) {
                    songSearchTextField
                        .padding(.horizontal)
                    headerItems
                    songList
                }
            }
            .scrollIndicators(.never)
            .disabled(viewModel.searchActive)
            .blur(radius: viewModel.searchActive ? 5 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }
    
    private var navHeaderItems: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(.clear)
                    .frame(width: 44)
            }
            
            Spacer()
            
            Text("Desmond's Songs")
                .foregroundStyle(.oreo)
                .font(.title2.bold())
                .fontDesign(.rounded)
                .frame(maxWidth: .infinity)
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(.oreo)
                    .frame(width: 44)
                    .shadow(radius: 2)
                Image(systemName: "folder.fill.badge.plus")
                    .bold()
                    .foregroundStyle(.white)
            }
            .onTapGesture {
                withAnimation(.bouncy(duration: 0.4)) {
                    moveSet -= UIScreen.main.bounds.width
                }
            }
        }
        .padding(.top)
        .padding(.bottom, 8)
        .blur(radius: viewModel.searchActive ? 5 : 0)
    }
    private var songSearchTextField: some View {
        TextField("", text: $text)
            .textFieldStyle(CustomTextFieldStyle(text: $text, placeholder: "Search for song", icon: "magnifyingglass"))
            .autocorrectionDisabled()
            .padding(.vertical, 8)
            .onChange(of: text) { _, _ in
                viewModel.filterSongsByText(text: text, songs: &songService.sortedSongs, songItems: songService.searchResultSongs)
            }
    }
    private var headerItems: some View {
        HStack {
            Text("RANK")
            
            Spacer()
            
            Button {
                Task {
                    await viewModel.togglePlayCountSort(songs: &songService.sortedSongs)
                }
            } label: {
                HStack {
                    Text("PLAYS")
                    Image(systemName: "chevron.down")
                        .bold()
                        .rotationEffect(.degrees(viewModel.playCountAscending ? 180 : 0))
                }
            }
        }
        .font(.subheadline.bold())
        .opacity(0.7)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
    private var songList: some View {
        LazyVStack {
            ForEach(Array(songService.sortedSongs.enumerated()), id: \.offset) { index, song in
                SongListRow(song: song, index: viewModel.playCountAscending ? ((songService.sortedSongs.count - 1) - index) : index)
            }
        }
    }
}

#Preview {
    SongList(moveSet: .constant(.zero))
        .environment(SongService())
        .environment(SongListViewModel())
}

struct SongListRow: View {
    let song: Song
    let index: Int
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    Image(systemName: "seal.fill")
                        .font(.title)
                        .foregroundStyle(index == 0 ? .naranja : .clear)
                    Text("\(index + 1)")
                        .fontWeight(.semibold)
                        .foregroundStyle(index == 0 ? .white : .primary)
                }
                .padding(.trailing, 8)
                
                if let artwork = song.artwork {
                    ArtworkImage(artwork, width: 44)
                        .clipShape(.rect(cornerRadius: 22, style: .continuous))
                        .shadow(radius: 2)
                } else {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .foregroundStyle(.gray.opacity(0.8))
                        .frame(width: 44, height: 44)
                }
                
                VStack(alignment: .leading) {
                    Text(song.title)
                        .fontWeight(.semibold)
                    Text(song.artistName)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 4)
                .lineLimit(1)
                
                Spacer()
                
                Text("\(song.playCount ?? 0)")
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

struct CustomTextFieldStyle: TextFieldStyle {
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            Image(systemName: icon)
            ZStack {
                Text(placeholder)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(text.isEmpty ? 1.0 : 0)
                configuration
                    .foregroundStyle(.oreo)
            }
        }
        .bold()
        .foregroundStyle(.oreo)
        .padding(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white)
                .shadow(color: .gray.opacity(0.4), radius: 2)
        )
    }
}
