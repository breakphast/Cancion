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
    var queueCount = 0
    var filterActive = false
    var moveSet: CGFloat = .zero
    var nextIndex = 1
    var playerState = ApplicationMusicPlayer.shared.state
    var progress: CGFloat = .zero
    var isPlaying: Bool {
        return (playerState.playbackStatus == .playing)
    }
    var customQueueSong: Song? = nil
    var currentTimer: Timer? = nil
    var generatorActive = false
    var observing = false
    var isPlaybackQueueSet = false
    
    var cancion: Song?
    var altQueueActive = false
    
    func setQueue(cancion: Song) {
        player.queue = [cancion]
        Task {
            try await player.prepareToPlay()
        }
    }
    
    func startObservingCurrentTrack(cancion: Song) {
        currentTimer?.invalidate()
        
        currentTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self, isPlaying else {
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
            cancion = songs[nextIndex]
            nextIndex += 1
            if let cancion {
                if altQueueActive {
                    try await player.play()
                    altQueueActive = false
                }
                startObservingCurrentTrack(cancion: cancion)
            }
        } catch {
            
        }
    }
}
