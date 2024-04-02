//
//  PlaylistGeneratorTests.swift
//  CancionTests
//
//  Created by Desmond Fitch on 3/21/24.
//

import XCTest
import MusicKit
import SwiftUI
@testable import Cancion

final class PlaylistGeneratorTests: XCTestCase {
    var authService: AuthService!
    var viewModel: PlaylistGeneratorViewModel!
    var songService: SongService!
    
    override func setUpWithError() throws {
        super.setUp()

        authService = AuthService()
        viewModel = PlaylistGeneratorViewModel()
        songService = SongService()

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

    func testFetchMatchingSongsUsingArtistNameUsingEqualsCondition() async throws {
        if let testArtistSong = songService.ogSongs.first {
            let artist = testArtistSong.artistName
            let filter = Filter(type: FilterType.artist.rawValue, value: artist, condition: Condition.equals.rawValue)
            
            let songIDs = await viewModel.fetchMatchingSongIDs(songs: songService.ogSongs, filters: [filter], matchRules: "all", limitType: LimitType.items.rawValue)
            let actualSongs = songService.sortedSongs.filter { songIDs.contains($0.id.rawValue) }
            let nonMatching = actualSongs.filter { $0.artistName != artist }
            
            XCTAssertTrue(!songIDs.isEmpty)
            XCTAssertTrue(nonMatching.isEmpty)
            XCTAssertTrue(actualSongs.map {$0.artistName == artist}.count == songIDs.count)
        } else {
            XCTFail("No songs to test.")
        }
    }
    
    func testFetchMatchingSongsUsingArtistNameUsingContainsCondition() async throws {
        if let testArtistSong = songService.ogSongs.first {
            let ogArtistName = testArtistSong.artistName
            let artistNameChunk = Helpers.getRandomSubstring(from: testArtistSong.artistName)
            let filter = Filter(type: FilterType.artist.rawValue, value: artistNameChunk, condition: Condition.contains.rawValue)
            
            let songIDs = await viewModel.fetchMatchingSongIDs(songs: songService.ogSongs, filters: [filter], matchRules: "all", limitType: LimitType.items.rawValue)
            let actualSongs = songService.sortedSongs.filter { songIDs.contains($0.id.rawValue) }
            
            XCTAssertTrue(!songIDs.isEmpty)
            XCTAssert(!actualSongs.map {$0.artistName == ogArtistName}.isEmpty)
        } else {
            XCTFail("No songs to test.")
        }
    }
    
    func testAssignValues() async throws {
        let playlista = Playlista(title: "Desmond's")
        let filter = Filter(date: Helpers().dateFormatter.string(from: Date()))
        await viewModel.assignViewModelValues(playlist: playlista, filters: [filter])
        XCTAssertTrue(viewModel.playlistName == playlista.name)
        XCTAssertTrue(!viewModel.filteredDates.isEmpty)
        
        await viewModel.resetViewModelValues()
        XCTAssertTrue(viewModel.playlistName.isEmpty)
    }
    
    func testGeneratePlaylistUsingDates() async throws {
        if let songWithDate = songService.ogSongs.first(where: {$0.libraryAddedDate != nil}), let date = songWithDate.libraryAddedDate {
            let dateString = Helpers().datePickerFormatter.string(from: date)
            
            let filter = Filter(type: FilterType.dateAdded.rawValue, value: "", condition: Condition.equals.rawValue, date: dateString)
            viewModel.filteredDates[filter.id.uuidString] = dateString
            let songIDs = await viewModel.fetchMatchingSongIDs(songs: songService.ogSongs, filters: [filter], matchRules: "all", limitType: LimitType.items.rawValue)
            
            XCTAssertTrue(songIDs.contains(songWithDate.id.rawValue))
        } else {
            XCTFail("Matching function did not return given song.")
        }
    }
}
