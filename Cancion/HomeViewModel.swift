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
    @MainActor var cancion: Song?
    
    var filterActive = false
    var progress: CGFloat = .zero
    var nextIndex = 0
    
    var customQueueSong: Song? = nil
    var currentTimer: Timer? = nil
    
    var generatorActive = false
    var isPlaybackQueueSet = false
    var altQueueActive = false
    var songService = SongService()
    var changing = false
    var blockExternalChange = false
    var previousQueueEntryID: String?
    let swipeThreshold: CGFloat = 50.0
    var currentScreen: Screen = .player
    
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
    func handleAutoQueue(forward: Bool) {
        print("Queue auto progressing...")
        changing = true
        nextIndex += (forward ? 1 : -1)
        cancion = songService.randomSongs[nextIndex]
        startObservingCurrentTrack(cancion: songService.randomSongs[nextIndex])
        blockExternalChange = false
        changing = false
    }
    
    @MainActor
    func initializeQueue(songs: [Song]) {
        Task {
            do {
                if let song = songs.first {
                    cancion = song
                }
                player.queue = ApplicationMusicPlayer.Queue(for: songs, startingAt: songs[0])
                try await player.prepareToPlay()
                
                isPlaybackQueueSet = true
                if let cancion {
                    startObservingCurrentTrack(cancion: cancion)
                }
            } catch {
                
            }
        }
    }
    
    @MainActor
    func handlePlayButtonSelected() {
        Task {
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
                            print("Failed to resume playing with error: \(error).")
                        }
                    }
                }
            } else {
                withAnimation {
                    player.pause()
                }
            }
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
        guard !blockExternalChange && !changing else { return }
        blockExternalChange = true
        changing = true
        do {
            progress = .zero
            nextIndex += (forward ? 1 : -1)
            cancion = songs[nextIndex]
            startObservingCurrentTrack(cancion: songs[nextIndex])
            try await (forward ? player.skipToNextEntry() : player.skipToPreviousEntry())
        } catch {
            print("ERROR:", error.localizedDescription)
        }
    }
    
    @MainActor
    func handleSongSelected(song: Song) {
        guard !blockExternalChange && !changing else { return }
        
        blockExternalChange = true
        changing = true
        let songs = songService.randomSongs
        songService.randomSongs.removeAll(where: {$0.id == song.id})
        songService.randomSongs[nextIndex] = song
        cancion = song
        startObservingCurrentTrack(cancion: song)
        Task {
            try await player.queue.insert(song, position: .afterCurrentEntry)
            try await player.skipToNextEntry()
            isPlaybackQueueSet = true
            try await player.play()
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

enum Screen {
    case player
    case songs
    case playlists
    case playlistView
    case playlistGen
}
