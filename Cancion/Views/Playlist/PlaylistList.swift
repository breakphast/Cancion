//
//  PlaylistList.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/27/24.
//

import SwiftUI
import MusicKit

struct PlaylistList: View {
    @State var viewModel = PlaylistGeneratorViewModel()
    @Environment(HomeViewModel.self) var homeViewModel
    @Binding var moveSet: CGFloat
    @State private var text: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                navHeaderItems
                ScrollView {
                    VStack(alignment: .leading) {
                        songSearchTextField
                            .padding(.horizontal)
                        
                        LazyVStack {
                            HStack(spacing: 16) {
                                newPlaylistButton
                                Spacer()
                            }
                            CustomDivider()
                            
                            ForEach(viewModel.playlists, id: \.id) { playlist in
                                PlaylistListRow(playlist: playlist)
                                    .onTapGesture {
                                        viewModel.setActivePlaylist(playlist: playlist)
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .offset(x: moveSet + (UIScreen.main.bounds.width * 2))
            .fullScreenCover(isPresented: $viewModel.showView) {
                if let activePlaylist = viewModel.activePlaylist {
                    PlaylistView(moveSet: $moveSet, showView: $viewModel.showView, playlist: activePlaylist)
                }
            }
            
            VStack {
                PlaylistGenerator(viewModel: viewModel, moveSet: $moveSet)
                    .environment(viewModel)
            }
            .offset(x: moveSet + (UIScreen.main.bounds.width * 3))
        }
    }
    private var newPlaylistButton: some View {
        Button {
            withAnimation(.bouncy(duration: 0.4)) {
                moveSet -= UIScreen.main.bounds.width
                homeViewModel.generatorActive = true
            }
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.naranja.opacity(0.8))
                        .frame(width: 44, height: 44)
                    Image(systemName: "plus")
                        .font(.title2.bold())
                }
                Text("New Playlist...")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
        }
    }
    private var navHeaderItems: some View {
        HStack {
            Button {
                withAnimation(.bouncy(duration: 0.4)) {
                    moveSet += UIScreen.main.bounds.width
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.oreo)
                        .frame(width: 44)
                        .shadow(radius: 2)
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                        .font(.headline)
                        .fontWeight(.heavy)
                }
            }
            
            Spacer()
            
            Text("Smart Playlists")
                .foregroundStyle(.oreo)
                .font(.title2.bold())
                .fontDesign(.rounded)
            
            Spacer()
            
            Button {
                withAnimation(.bouncy(duration: 0.4)) {
                    moveSet += UIScreen.main.bounds.width
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.oreo)
                        .frame(width: 44)
                        .shadow(radius: 2)
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .foregroundStyle(.white)
                        .font(.title2)
                        .fontWeight(.heavy)
                }
            }
        }
        .padding(.top)
        .padding(.bottom, 8)
    }
    private var songSearchTextField: some View {
        TextField("", text: $text)
            .textFieldStyle(CustomTextFieldStyle(text: $text, placeholder: "Search for song in playlist", icon: "magnifyingglass"))
            .autocorrectionDisabled()
            .padding(.vertical, 8)
            .onChange(of: text) { _, _ in
                
            }
    }
}

#Preview {
    PlaylistList(moveSet: .constant(UIScreen.main.bounds.width * -2))
        .environment(PlaylistGeneratorViewModel())
        .environment(SongService())
}
