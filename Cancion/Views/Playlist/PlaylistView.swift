//
//  PlaylistView.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/27/24.
//

import SwiftUI
import MusicKit
import SwiftData
import CoreData

struct PlaylistView: View {
    @Environment(SongService.self) var songService
    @Environment(HomeViewModel.self) var homeViewModel
    @Environment(PlaylistGeneratorViewModel.self) var playlistGeneratorViewModel
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Query var filtersQuery: [Filter]
    
    @Environment(PlaylistViewModel.self) var viewModel
    @State private var text: String = ""
    var playCountAscending = false
    
    @FocusState var isFocused: Bool
    @Binding var showView: Bool
    @Binding var activePlaylist: Playlistt?
    @State private var showGenerator = false
    @State private var scrollID: String?
    
    var playlist: Playlistt
    var songs: [Song] {
        let playlistSongs = viewModel.playlistSongs
        return text.isEmpty ? playlistSongs : playlistSongs.filter { $0.title.contains(text) || $0.artistName.contains(text) }
    }
    var coverImage: Image? {
        if let cover = playlistGeneratorViewModel.coverData {
            if let uiImage = UIImage(data: cover) {
                return Image(uiImage: uiImage)
            }
        }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 16) {
            navHeaderItems
                .padding(.horizontal, 24)
            
            ScrollView {
                VStack(alignment: .center) {
                    songSearchTextField
                    playlistCover
                        .id("cover")
                    headerItems
                    songList
                }
                .padding(.top, 4)
                .padding(.horizontal, 24)
            }
            .scrollIndicators(.never)
            .scrollPosition(id: $scrollID)
            .disabled(viewModel.searchActive)
            .blur(radius: viewModel.searchActive ? 5 : 0)
        }
        .frame(maxWidth: .infinity)
        .gesture(homeViewModel.swipeGesture)
        .fullScreenCover(isPresented: $showGenerator) {
            EditPlaylistView(playlist: playlist)
        }
        .onChange(of: homeViewModel.currentScreen) { _, _ in
            isFocused = false
        }
        .onChange(of: playlist.cover ?? Data(), { _, newCover in
            playlistGeneratorViewModel.coverData = newCover
        })
        .onAppear {
            scrollID = "cover"
        }
        .onChange(of: viewModel.songSort, { _, songSort in
            viewModel.assignSortTitles(sortType: songSort)
        })
        .onChange(of: songService.playlistSongs) { _, newSongs in
            viewModel.playlistSongs = newSongs
        }
    }
    
    private var navHeaderItems: some View {
        HStack {
            Button {
                withAnimation {
                    dismiss()
                    showView = false
                    homeViewModel.playlistSongSort = nil
                }
                withAnimation {
                    Task {
                        playlistGeneratorViewModel.resetViewModelValues()
                        viewModel.resetPlaylistViewModelValues()
                    }
                    dismiss()
                    showView = false
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.oreo)
                        .frame(width: 44)
                        .shadow(radius: 2)
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                        .font(.headline)
                        .fontWeight(.heavy)
                }
            }
            
            Spacer()
            
            Text(playlist.name)
                .foregroundStyle(.oreo)
                .font(.title2.bold())
                .fontDesign(.rounded)
                .frame(maxWidth: .infinity)
            
            Spacer()
            
            Button {
                withAnimation {
                    showGenerator.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.oreo)
                        .frame(width: 44)
                        .shadow(radius: 2)
                    Image(systemName: "pencil")
                        .foregroundStyle(.white)
                        .font(.headline)
                        .fontWeight(.black)
                }
            }
        }
        .padding(.top)
        .blur(radius: viewModel.searchActive ? 5 : 0)
    }
    private var songSearchTextField: some View {
        TextField("", text: $text)
            .textFieldStyle(CustomTextFieldStyle(text: $text, placeholder: "Search for song", icon: "magnifyingglass"))
            .autocorrectionDisabled()
            .padding(.horizontal)
            .focused($isFocused)
            .onChange(of: text) { _, _ in
                text = text
                viewModel.filterSongsByText(text: text, songs: &songService.playlistSongs, using: songService.ogPlaylistSongs)
            }
    }
    private var headerItems: some View {
        HStack {
            Spacer()
            
            Button {
                viewModel.playCountAscending.toggle()
                
            } label: {
                HStack(spacing: 4) {
                    Text(viewModel.sortTitle)
                    Image(systemName: "chevron.down")
                        .bold()
                        .rotationEffect(.degrees(viewModel.playCountAscending ? 180 : 0))
                }
            }
        }
        .font(.subheadline.bold())
        .opacity(0.7)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    private var playlistCover: some View {
        ZStack {
            if let coverImage {
                coverImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 200)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.white)
                            .shadow(radius: 3)
                    )
                    .padding()
            } else if let songID = playlist.songs.first, let songID2 = playlist.songs.last, let song1 = Array(songService.ogSongs).first(where: { $0.id.rawValue == songID }), let song2 = Array(songService.ogSongs).first(where: { $0.id.rawValue == songID2 }) {
                if let artwork1 = song1.artwork, let artwork2 = song2.artwork  {
                    HStack(spacing: 0) {
                        ArtworkImage(artwork1, width: 200)
                        ArtworkImage(artwork2, width: 200)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 200)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.white)
                            .shadow(radius: 3)
                    )
                    .padding()
                } else {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.oreo.opacity(0.6))
                        .shadow(radius: 5)
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: 200)
                        .padding(.vertical)
                }
            }
        }
    }
    private var songList: some View {
        VStack {
            ForEach(Array(songs.enumerated()), id: \.offset) { index, song in
                SongListRow(song: song, index: viewModel.playCountAscending ? ((viewModel.playlistSongs.count - 1) - index) : index)
                    .onTapGesture {
                        Task {
                            let upperBound = index + 50 > viewModel.playlistSongs.count ? viewModel.playlistSongs.count : index + 20
                            let selectedSongs = Array(viewModel.playlistSongs[index..<upperBound])
                            
                            await homeViewModel.handleSongSelected(song: song, songs: selectedSongs)
                        }
                    }
            }
        }
    }
    
    func deleteAnyCoreDataPersistentStore() {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)

        if let appSupportURL = urls.last {
            do {
                // List all files in the application support directory
                let filePaths = try fileManager.contentsOfDirectory(atPath: appSupportURL.path)
                
                for filePath in filePaths {
                    // Check for any file related to Core Data (e.g., .sqlite, .sqlite-shm, .sqlite-wal)
                    if filePath.contains("sqlite") || filePath.contains("sqlite-shm") || filePath.contains("sqlite-wal") {
                        let fullPath = appSupportURL.appendingPathComponent(filePath).path
                        try fileManager.removeItem(atPath: fullPath)
                        print("Deleted Core Data store: \(fullPath)")
                    }
                }
            } catch {
                print("Error deleting Core Data persistent store: \(error)")
            }
        }
    }
    
    func countItemsInPersistentContainer() {
        let persistentContainer = NSPersistentContainer(name: "Playlista")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                print("Failed to load Core Data store: \(error)")
                return
            }

            let context = persistentContainer.viewContext
            let entityNames = persistentContainer.managedObjectModel.entities.compactMap { $0.name }
            
            var totalObjectsCount = 0
            
            for entityName in entityNames {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                
                do {
                    let count = try context.count(for: fetchRequest)
                    totalObjectsCount += count
                    print("Entity: \(entityName), Count: \(count)")
                } catch {
                    print("Failed to fetch count for entity \(entityName): \(error)")
                }
            }
            
            print("Total number of items in Core Data: \(totalObjectsCount)")
            
            // Now proceed to delete the persistent store
            if totalObjectsCount > 0 {
                deletePersistentStore()
            } else {
                print("Persistent store is already empty.")
            }
        }
    }

    // Function to delete the persistent store
    func deletePersistentStore() {
        let persistentContainer = NSPersistentContainer(name: "Playlista")
        let storeURL = persistentContainer.persistentStoreDescriptions.first?.url
        if let storeURL = storeURL {
            do {
                try FileManager.default.removeItem(at: storeURL)
                print("Core Data store deleted successfully.")
            } catch {
                print("Failed to delete Core Data store: \(error)")
            }
        }
    }
}
