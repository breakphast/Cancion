//
//  PlaylistGeneratorTests.swift
//  CancionTests
//
//  Created by Desmond Fitch on 3/21/24.
//

import XCTest
import MusicKit
import SwiftUI
import SwiftData
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
            
            let songIDs = await viewModel.fetchMatchingSongIDs(songs: songService.ogSongs, filters: [filter], matchRules: "all", limit: 25, limitType: LimitType.items.rawValue, limitSortType: LimitSortType.mostPlayed.rawValue)
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
            
            let songIDs = await viewModel.fetchMatchingSongIDs(songs: songService.ogSongs, filters: [filter], matchRules: "all", limit: 25, limitType: LimitType.items.rawValue, limitSortType: LimitSortType.mostPlayed.rawValue)
            let actualSongs = songService.sortedSongs.filter { songIDs.contains($0.id.rawValue) }
            
            XCTAssertTrue(!songIDs.isEmpty)
            XCTAssert(!actualSongs.map {$0.artistName == ogArtistName}.isEmpty)
        } else {
            XCTFail("No songs to test.")
        }
    }
    
    func testFetchMatchingSongsSortedByLastPlayed() async throws {
        let filter = Filter(type: FilterType.artist.rawValue, value: "Yeat", condition: Condition.contains.rawValue)
        
        let songIDs = await viewModel.fetchMatchingSongIDs(songs: songService.ogSongs, filters: [filter], matchRules: "all", limit: 25, limitType: LimitType.items.rawValue, limitSortType: LimitSortType.lastPlayed.rawValue)
        let lastPlayedDates = songService.sortedSongs.filter { songIDs.contains($0.id.rawValue) }.compactMap { $0.lastPlayedDate }
        let dateAddedDates = songService.sortedSongs.filter { songIDs.contains($0.id.rawValue) }.compactMap { $0.libraryAddedDate }
        
        guard !lastPlayedDates.isEmpty && !dateAddedDates.isEmpty else {
            XCTFail()
            return
        }
        XCTAssertNotEqual(lastPlayedDates, dateAddedDates)
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
            let songIDs = await viewModel.fetchMatchingSongIDs(songs: songService.ogSongs, filters: [filter], matchRules: "all", limit: 25, limitType: LimitType.items.rawValue, limitSortType: LimitSortType.mostPlayed.rawValue)
            
            XCTAssertTrue(songIDs.contains(songWithDate.id.rawValue))
            
            viewModel.playlistName = "Patrick"
            let newPlaylist = await viewModel.generatePlaylist(songs: songService.ogSongs, name: "Patrick", filters: [filter], limit: 25, limitType: LimitType.items.rawValue, limitSortType: LimitSortType.mostPlayed.rawValue)
            XCTAssertNotNil(newPlaylist)
            let addedPlaylist = await viewModel.addPlaylist(songs: songService.ogSongs)
            XCTAssertNotNil(addedPlaylist)
            
            let matchingSongs = songService.ogSongs.filter {
                songIDs.contains($0.id.rawValue)
            }.compactMap { $0.libraryAddedDate }
            
            
            let songDates = matchingSongs.filter { !areDatesEqual(date1: $0, date2: date) }
            XCTAssertTrue(songDates.isEmpty)
        } else {
            XCTFail("Matching function did not return given song.")
        }
    }
    
    func testSaveToModelContext() async throws {
        var modelContxt: ModelContext = ModelContext(try ModelContainer(for: Playlista.self, Filter.self))
        let filter = Filter(type: FilterType.artist.rawValue, value: "Yeat", condition: Condition.equals.rawValue)
        viewModel.filterModels = [filter]

        let playlista = Playlista(title: "ELlo", filters: [filter.id.uuidString])
        let addedToContext = viewModel.addModelAndFiltersToDatabase(model: playlista, modelContext: modelContxt)
        
        XCTAssertEqual(modelContxt.container.schema.entities.count, 2)
        XCTAssertTrue(addedToContext)
    }
    
    func testHandleResetValues() async throws {
        viewModel.playlistName = "JONATHAN"
        await viewModel.resetViewModelValues()
        XCTAssertTrue(viewModel.playlistName.isEmpty)
    }
}
