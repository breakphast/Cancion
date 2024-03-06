//
//  PlaylistList.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/27/24.
//

import SwiftUI
import MusicKit
import SwiftData

struct PlaylistList: View {
    @State var viewModel = PlaylistGeneratorViewModel()
    @Environment(HomeViewModel.self) var homeViewModel
    @State private var text: String = ""
    @Environment(\.modelContext) var modelContext
    @Query var playlistas: [Playlista]
    
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
                            
                            ForEach(playlistas, id: \.id) { playlist in
                                PlaylistListRow(playlist: playlist)
                                    .environment(viewModel)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .offset(x: homeViewModel.moveSet + (UIScreen.main.bounds.width * 2))
            .fullScreenCover(isPresented: $viewModel.showView) {
                if let activePlaylist = viewModel.activePlaylist {
                    PlaylistView(showView: $viewModel.showView, playlist: activePlaylist)
                }
            }
            .onChange(of: text) { _, _ in
                text = text
            }
            
            VStack {
                PlaylistGenerator(viewModel: viewModel)
                    .environment(viewModel)
            }
            .offset(x: homeViewModel.moveSet + (UIScreen.main.bounds.width * 3))
        }
    }
    private var newPlaylistButton: some View {
        Button {
            withAnimation(.bouncy(duration: 0.4)) {
                homeViewModel.moveSet -= UIScreen.main.bounds.width
                homeViewModel.generatorActive = true
            }
        } label: {
            HStack {
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
                    homeViewModel.moveSet += UIScreen.main.bounds.width
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
                    homeViewModel.moveSet += UIScreen.main.bounds.width
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
    }
}

#Preview {
    PlaylistList()
        .environment(PlaylistGeneratorViewModel())
        .environment(SongService())
}
