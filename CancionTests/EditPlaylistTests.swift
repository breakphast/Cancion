//
//  EditPlaylistTests.swift
//  CancionTests
//
//  Created by Desmond Fitch on 4/1/24.
//

import XCTest
import MusicKit
import SwiftUI
@testable import Cancion

final class EditPlaylistTests: XCTestCase {
    var authService: AuthService!
    var viewModel: EditPlaylistViewModel!
    var songService: SongService!
    var playlista: Playlista!
    
    override func setUpWithError() throws {
        super.setUp()

        authService = AuthService()
        viewModel = EditPlaylistViewModel()
        songService = SongService()
        playlista = Playlista()

        let expectation = XCTestExpectation(description: "Setup async operations")
        
        Task {
            try await setupSongsForTesting()

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }
    
    func setupSongsForTesting() async throws {
        try await songService.smartFilterSongs(limit: 2000, by: .playCount)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEditPlaylistName() async throws {
        let filter = Filter(type: FilterType.artist.rawValue, value: "Yeat", condition: Condition.equals.rawValue)
        playlista.name = "HIHI"
        viewModel.playlistName = "GOGO"
        let edit = await viewModel.handleEditPlaylist(songService: songService, playlist: playlista, filters: [filter])
        
        if edit {
            print(playlista.name, viewModel.playlistName)
            XCTAssertTrue(playlista.name == viewModel.playlistName)
        } else {
            XCTFail()
        }
    }
}
