//
//  HomeViewModel.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/26/24.
//

import SwiftUI
import Foundation
import Combine
import MusicKit

@Observable final class HomeViewModel {
    var player = ApplicationMusicPlayer.shared
    var playerState = ApplicationMusicPlayer.shared.state
    var isPlaying: Bool {
        return (playerState.playbackStatus == .playing)
    }
    var cancion: Song?
    var filterActive = false
    var progress: CGFloat = .zero
    var currentTimer: Timer? = nil
    
    var generatorActive = false
    var isPlaybackQueueSet = false
    var selectionChange = false
    let swipeThreshold: CGFloat = 50.0
    var currentScreen: Screen = .player
    var queueActive = false
    
    var songSort: SongSortOption = .plays
    var playlistSongSort: LimitSortType?
    
    var emptySongsInit = false
    
    let dateFormatter = DateFormatter()
    init() {
        dateFormatter.dateFormat = "M/d/yy"
    }
    
    var ogSongs = [Song]()
    var sortedSongs = [Song]()
    var randomSongs = [Song]()
    
    
    var moveSet: CGFloat {
        switch currentScreen {
        case .player:
            return .zero
        case .songs:
            return -UIScreen.main.bounds.width
        case .playlists, .playlistView:
            return (-UIScreen.main.bounds.width * 2)
        case .playlistGen:
            return (-UIScreen.main.bounds.width * 3)
        }
    }
    
    func startObservingCurrentTrack(cancion: Song) {
        currentTimer?.invalidate()
        
        currentTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self, isPlaying else {
                return
            }
            let currentPlaybackTime = self.player.playbackTime
            let totalDuration = cancion.duration ?? .zero
            print("Observing: ", cancion.title)
            if !totalDuration.isZero {
                withAnimation(.linear) {
                    self.progress = CGFloat(currentPlaybackTime / totalDuration)
                }
            }
        }
    }
    
    @MainActor
    func findMatchingSong(entry: MusicPlayer.Queue.Entry) {
        switch entry.item {
        case .song(let song):
            if let songSong = Array(ogSongs).first(where: { $0.title == song.title && $0.artistName == song.artistName }) {
                cancion = songSong
                startObservingCurrentTrack(cancion: songSong)
            }
        default:
            return
        }
    }
    
    func handleSongsInit(songService: SongService) async throws {
        do {
            try await songService.smartFilterSongs(limit: 1500, by: .playCount)
            ogSongs = songService.ogSongs
            await initializeQueue(songs: songService.randomSongs)
        } catch {
            print("Failed to initialize queue.")
        }
    }

    func initializeQueue(songs: [Song]) async {
        guard let song = songs.first else {
            if songs.isEmpty {
                emptySongsInit = true
            }
            return
        }

        var endIndex = max(songs.count / 20, 1)
        endIndex = min(endIndex, songs.count)

        player.queue = ApplicationMusicPlayer.Queue(for: songs[0 ..< endIndex], startingAt: song)
        do {
            try await player.prepareToPlay()
            isPlaybackQueueSet = true
        } catch {
            print("Failed to play.")
        }
        
        cancion = song
        if let cancion {
            startObservingCurrentTrack(cancion: cancion)
        }
    }
    
    func handlePlayButtonSelected() {
        if !isPlaying {
            if !isPlaybackQueueSet, let cancion {
                player.queue = [cancion]
                isPlaybackQueueSet = true
                beginPlaying()
            } else if let cancion = cancion {
                Task {
                    do {
                        try await player.play()
                        startObservingCurrentTrack(cancion: cancion)
                    } catch {
                        print("Failed to resume playing with error: \(error.localizedDescription).")
                        player = ApplicationMusicPlayer.shared
                        player.queue.entries.removeAll()
                        isPlaybackQueueSet = false
                    }
                }
            }
        } else {
            withAnimation {
                player.pause()
            }
        }
    }
    
    func handleQueueChange(old: MusicPlayer.Queue.Entry?, new: MusicPlayer.Queue.Entry?) {
        Task { @MainActor in
            guard old != nil, let new else {
                if selectionChange, let new {
                    findMatchingSong(entry: new)
                }
                return
            }
            
            selectionChange = false
            queueActive = true
            findMatchingSong(entry: new)
        }
    }
    
    private func beginPlaying() {
        Task { @MainActor in
            do {
                try await player.play()
                if let cancion {
                    startObservingCurrentTrack(cancion: cancion)
                }
            } catch {
                print("Failed to play with error: \(error).")
            }
        }
    }
    
    @MainActor
    func handleChangePress(songs: [Song], forward: Bool) async throws {
        do {
            progress = .zero
            try await (forward ? player.skipToNextEntry() : player.skipToPreviousEntry())
        } catch {
            print("ERROR:", error.localizedDescription)
        }
    }
    
    func handleSongSelected(song: Song) async {
        selectionChange = true
        do {
            try await player.queue.insert(song, position: .afterCurrentEntry)
            try await player.skipToNextEntry()
            isPlaybackQueueSet = true
            try await player.play()
        } catch {
            
        }
    }
    
    var swipeGesture: some Gesture {
        DragGesture(minimumDistance: swipeThreshold)
            .onEnded { value in
                let horizontalDistance = value.translation.width
                let verticalDistance = value.translation.height
                let isHorizontalSwipe = abs(horizontalDistance) > abs(verticalDistance)
                
                if isHorizontalSwipe && abs(horizontalDistance) > self.swipeThreshold {
                    if horizontalDistance < 0 {
                        withAnimation(.bouncy(duration: 0.4)) {
                            switch self.currentScreen {
                            case .player:
                                self.currentScreen = .songs
                            case .songs:
                                self.currentScreen = .playlists
                            case .playlists:
                                return
                            case .playlistView:
                                return
                            case .playlistGen:
                                return
                            }
                        }
                    } else if horizontalDistance > 0 {
                        withAnimation(.bouncy(duration: 0.4)) {
                            switch self.currentScreen {
                            case .player:
                                return
                            case .songs:
                                self.currentScreen = .player
                            case .playlists:
                                self.currentScreen = .songs
                            case .playlistView:
                                return
                            case .playlistGen:
                                return
                            }
                        }
                    }
                }
            }
    }
}
