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
