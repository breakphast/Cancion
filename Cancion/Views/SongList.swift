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
    @Environment(HomeViewModel.self) var homeViewModel
    @State private var text: String = ""
    @Binding var moveSet: CGFloat
    @State var scrollID: Int?
    var body: some View {
        VStack {
            navHeaderItems
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    songSearchTextField
                        .id(0)
                    headerItems
                        .id(33)
                    songList
                        .id(2)
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.never)
            .scrollPosition(id: $scrollID)
            .scrollTargetBehavior(.viewAligned)
            .disabled(viewModel.searchActive)
            .blur(radius: viewModel.searchActive ? 5 : 0)
            .contentMargins(16, for: .scrollContent)
            .task {
                scrollID = 33
            }
        }
        .padding(.horizontal)
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
        .padding(.vertical, 8)
    }
    private var songList: some View {
        LazyVStack {
            ForEach(Array(songService.sortedSongs.enumerated()), id: \.offset) { index, song in
                SongListRow(song: song, index: viewModel.playCountAscending ? ((songService.sortedSongs.count - 1) - index) : index)
                    .onTapGesture {
                        Task {
                            homeViewModel.player.stop()
                            homeViewModel.player.queue = []
                            homeViewModel.setQueue(cancion: song, custom: true)
                        }
                    }
            }
        }
    }
}

#Preview {
    SongList(moveSet: .constant(.zero))
        .environment(SongService())
        .environment(SongListViewModel())
}
