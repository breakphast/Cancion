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
    var nextIndex = 0
    var playerState = ApplicationMusicPlayer.shared.state
    var secondaryPlaying = false
    var progress: CGFloat = .zero
    var isPlaying: Bool {
        return (playerState.playbackStatus == .playing)
    }
    var customQueueSong: Song? = nil
    var currentTimer: Timer? = nil
    
    @MainActor
    func changeCancion(cancion: inout Song, songs: [Song]) async throws {
        cancion = songs[nextIndex]
        player.queue = [songs[nextIndex]]
        try await player.prepareToPlay()
        guard player.isPreparedToPlay else { return }
        if secondaryPlaying {
            try await playAndObserve(song: cancion)
            startObservingCurrentTrack(cancion: cancion)
        }
    }
    
    @MainActor
    func handleSongChange(forward: Bool) async throws {
        do {
            progress = .zero
            forward ? try await player.skipToNextEntry() : try await player.skipToPreviousEntry()
            nextIndex = nextIndex + (forward ? 1 : -1)
        } catch {
            print("Failed to change song", error.localizedDescription)
        }
    }
    func playAndObserve(song: Song) async throws {
        do {
            try await player.play()
        } catch {
            print("Could not play or observe.")
        }
    }
    func setQueue(cancion: Song, custom: Bool = false) {
        player.queue = [cancion]
        Task {
            try await player.prepareToPlay()
            if custom {
                self.customQueueSong = cancion
            }
        }
    }
    
    func startObservingCurrentTrack(cancion: Song) {
        currentTimer?.invalidate()
        
        currentTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self, secondaryPlaying == true else { return }
            print("Observing", cancion.title)
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
    
    func handlePlayButton() {
        Task {
            if !isPlaying {
                do {
                    try await player.play()
                } catch {
                    print("error", error.localizedDescription)
                }
            } else {
                player.pause()
            }
        }
    }
}
