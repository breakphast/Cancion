//
//  PlaylistViewTests.swift
//  CancionTests
//
//  Created by Desmond Fitch on 4/2/24.
//

import XCTest
import MusicKit
import SwiftUI
@testable import Cancion

final class PlaylistViewTests: XCTestCase {
    var authService: AuthService!
    var viewModel: PlaylistViewModel!
    var playlistGenViewModel: PlaylistGeneratorViewModel!

    var songService: SongService!
    var playlista: Playlistt!
    
    override func setUpWithError() throws {
        super.setUp()

        authService = AuthService()
        viewModel = PlaylistViewModel()
        songService = SongService()
        playlista = Playlistt()
        playlistGenViewModel = PlaylistGeneratorViewModel()

        let expectation = XCTestExpectation(description: "Setup async operations")
        
        Task {
            try await setupSongsForTesting()
            try await setupPlaylistForTesting()
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }
    
    func setupSongsForTesting() async throws {
        try await songService.smartFilterSongs(limit: 2000, by: .playCount)
    }
    
    func setupPlaylistForTesting() async throws {
        let filter = Filter(type: FilterType.artist.rawValue, value: "Yeat", condition: Condition.equals.rawValue)
        let testSongs = await playlistGenViewModel.fetchMatchingSongIDs(songs: songService.ogSongs, filters: [filter], matchRules: MatchRules.any.rawValue, limit: 25, limitType: LimitType.items.rawValue, limitSortType: LimitSortType.mostPlayed.rawValue)
        if !testSongs.isEmpty {
            viewModel.playlistSongs = songService.ogSongs.filter {
                testSongs.contains($0.id.rawValue)
            }
        }
//        if let testPlaylist = await playlistGenViewModel.generatePlaylist(songs: songService.ogSongs, name: "Patrick", filters: [filter], limit: 25, limitType: LimitType.items.rawValue, limitSortType: LimitSortType.mostPlayed.rawValue) {
//            viewModel.playlistSongs = testPlaylist.songs
//        }
    }
    
    func testFilterSongsByText() async throws {
        
    }
    
    func testAssignSongs() async throws {
        let originalPlaylistSongs = viewModel.playlistSongs
        viewModel.assignSongs(sortType: LimitSortType.lastPlayed)
        let newPlaylistSongs = viewModel.playlistSongs
        
        XCTAssertNotEqual(originalPlaylistSongs, newPlaylistSongs)
    }
}
