//
//  OpenRecentPlaylist.swift
//  Cancion
//
//  Created by Desmond Fitch on 9/30/24.
//

import SwiftUI
import AppIntents
import MusicKit
import SwiftData

struct OpenRecentPlaylist: AppIntent {
    var playlistaQuery = PlaylistaQuery()
    static let title: LocalizedStringResource = "Open Recent Playlist"
    static var description = IntentDescription("Opens the app and goes to your favorite trails.")
    let container: ModelContainer = {
        do {
            let container = try ModelContainer(for: Playlistt.self)
            return container
        } catch {
            fatalError("Failed to create container: \(error)")
        }
    }()
    
    let descriptor = FetchDescriptor<Playlistt>()
    
    @MainActor
    func perform() async throws -> some IntentResult {
        let context = container.mainContext
        let items = try context.fetch(descriptor)
//        let entities = try await playlistaQuery.entities(for: items.map {
//            $0.id
//        })
        if let firstPlaylist = items.first {
            playlistGenViewModel.activePlaylist = firstPlaylist
            playlistGenViewModel.showView = true
        }
        return .result()
    }
    
    static let openAppWhenRun: Bool = true
        
    @Dependency
    private var playlistViewModel: PlaylistViewModel
    
    @Dependency
    private var homeViewModel: HomeViewModel
    
    @Dependency
    private var playlistGenViewModel: PlaylistGeneratorViewModel
}
