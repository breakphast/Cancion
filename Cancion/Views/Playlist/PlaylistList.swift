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
    @FocusState var isFocused: Bool
    
    @State private var showGenerator = false
    
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            VStack {
                navHeaderItems
                    .padding(.horizontal, 24)
                ScrollView {
                    VStack(alignment: .leading) {
                        songSearchTextField
                        
                        LazyVStack {
                            HStack(spacing: 16) {
                                newPlaylistButton
                                Spacer()
                            }
                            CustomDivider()
                            
                            ForEach(playlistas, id: \.id) { playlist in
                                PlaylistListRow(playlist: playlist)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal, 24)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .offset(x: homeViewModel.moveSet + (UIScreen.main.bounds.width * 2))
            .fullScreenCover(isPresented: $viewModel.showView) {
                if let activePlaylist = viewModel.activePlaylist {
                    PlaylistView(showView: $viewModel.showView, playlist: activePlaylist)
                }
            }
            .fullScreenCover(isPresented: $showGenerator) {
                PlaylistGenerator()
                    .environment(viewModel)
            }
            .onChange(of: text) { _, _ in
                text = text
            }
        }
        .gesture(homeViewModel.swipeGesture)
        .environment(viewModel)
        .onChange(of: homeViewModel.currentScreen) { _, _ in
            isFocused = false
        }
    }
    private var newPlaylistButton: some View {
        Button {
            withAnimation(.bouncy(duration: 0.4)) {
                homeViewModel.generatorActive = true
                showGenerator = true
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
                    homeViewModel.currentScreen = .songs
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.oreo)
                        .frame(width: 44)
                        .shadow(radius: 2)
                    Image(systemName: "music.note.list")
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
            .focused($isFocused)
    }
}

#Preview {
    PlaylistList()
        .environment(PlaylistGeneratorViewModel())
        .environment(SongService())
}
