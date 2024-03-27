//
//  PlayerTests.swift
//  CancionTests
//
//  Created by Desmond Fitch on 3/27/24.
//

import XCTest
import MusicKit
import SwiftUI
@testable import Cancion

final class PlayerTests: XCTestCase {
    var authService: AuthService!
    var songService: SongService!
    var homeViewModel: HomeViewModel!

    override func setUpWithError() throws {
        authService = AuthService()
        songService = SongService()
        homeViewModel = HomeViewModel()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSongsInit() async throws {
        do {
            try await homeViewModel.handleSongsInit(songService: songService)
            XCTAssertFalse(songService.ogSongs.isEmpty)
        }
    }
    
    func testHandleSongSelected() async throws {
        do {
            try await homeViewModel.handleSongsInit(songService: songService)
            let queue = homeViewModel.player.queue

            if let song = songService.randomSongs.last {
                await homeViewModel.handleSongSelected(song: song)
                guard queue.entries.count > 1 else {
                    XCTFail("Queue does not contain expected number of entries.")
                    return
                }
                let newEntry = queue.entries[1]
                XCTAssertTrue(newEntry.title == song.title)
                
            } else {
                XCTFail("No songs available.")
            }
        }
    }
}
