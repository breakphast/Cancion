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
    var moveSet: CGFloat = .zero
    var progress: CGFloat = .zero
    var nextIndex = 0
    
    var customQueueSong: Song? = nil
    var currentTimer: Timer? = nil
    
    var generatorActive = false
    var isPlaybackQueueSet = true
    var altQueueActive = false
    var observing = false
    var songService = SongService()
    
    
    func startObservingCurrentTrack(cancion: Song) {
        currentTimer?.invalidate()
        if progress == .zero {
            
        }
        
        currentTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self, isPlaying else {
                if self?.progress == .zero {
                    
                }
                return
            }
            let currentPlaybackTime = self.player.playbackTime
            let totalDuration = cancion.duration ?? .zero
            
            if !totalDuration.isZero {
                withAnimation(.linear) {
                    self.progress = CGFloat(currentPlaybackTime / totalDuration)
                }
            }
            
            if self.progress >= 1.0 {
                timer.invalidate()
            }
        }
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
//                print(player.queue.entries[0..<5].map { $0.title })
                
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
                    print("HEREHRHE")
                    player.queue = [cancion]
                    isPlaybackQueueSet = true
                    beginPlaying()
                } else if let cancion = cancion {
                    Task {
                        do {
                            print("TRYING HERE")
                            try await player.play()
                            startObservingCurrentTrack(cancion: cancion)
                        } catch {
                            print("Failed to resume playing with error: \(error).")
                        }
                    }
                }
            } else {
                print("JUST PAUSING")
                player.pause()
            }
        }
    }
    
    private func beginPlaying() {
        Task {
            do {
                try await player.play()
                if let cancion {
                    startObservingCurrentTrack(cancion: cancion)
                }
            } catch {
                print("Failed to prepare to play with error: \(error).")
            }
        }
    }
    
    @MainActor
    func handleForwardPress(songs: [Song]) async throws {
        do {
            progress = .zero
            try await player.skipToNextEntry()
            nextIndex += 1
            cancion = songs[nextIndex]
//            if let cancion {
//                if altQueueActive {
//                    try await player.play()
//                    altQueueActive = false
//                }
//                startObservingCurrentTrack(cancion: cancion)
//            }
        } catch {
            
        }
    }
    
    func handleSongSelected(song: Song) {
        var songs = songService.randomSongs.shuffled()
        songs.removeAll(where: {$0.id == song.id})
        songs[0] = song
        songService.randomSongs = songs
        nextIndex = 0
        player.queue = ApplicationMusicPlayer.Queue(for: songService.randomSongs, startingAt: song)
        cancion = song
        startObservingCurrentTrack(cancion: song)
        Task {
            try await player.prepareToPlay()
            isPlaybackQueueSet = true
            try await player.play()
            
        }
    }
}
