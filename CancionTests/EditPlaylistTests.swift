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
    var playlista: Playlistt!
    
    override func setUpWithError() throws {
        super.setUp()

        authService = AuthService()
        viewModel = EditPlaylistViewModel()
        songService = SongService()
        playlista = Playlistt()

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
    
    func testEditPlaylistSongs() async throws {
        playlista.name = "JOJO"
        let filter = Filter(type: FilterType.artist.rawValue, value: "Yeat", condition: Condition.equals.rawValue)
        await viewModel.assignViewModelValues(playlist: playlista, filters: [filter])
        let _ = await viewModel.handleEditPlaylist(songService: songService, playlist: playlista, filters: [filter])
        let originalSongs = playlista.songs

        let filter1 = Filter(type: FilterType.artist.rawValue, value: "Lil Wop", condition: Condition.equals.rawValue)
        await viewModel.assignViewModelValues(playlist: playlista, filters: [filter1])
        let _ = await viewModel.handleEditPlaylist(songService: songService, playlist: playlista, filters: [filter1])
        let newSongs = playlista.songs
        XCTAssertNotEqual(originalSongs, newSongs)
    }
    
    func testEditPlaylistSongsWithInvalidFilter() async throws {
        playlista.name = "JOJO"
        let filter = Filter(type: FilterType.artist.rawValue, value: "Yeaters", condition: Condition.equals.rawValue)
        await viewModel.assignViewModelValues(playlist: playlista, filters: [filter])
        let edit = await viewModel.handleEditPlaylist(songService: songService, playlist: playlista, filters: [filter])
        
        XCTAssertFalse(edit)
    }
    
    func testEditPlaylistWithEmptyName() async throws {
        playlista.name = ""
        let filter = Filter(type: FilterType.artist.rawValue, value: "Yeat", condition: Condition.equals.rawValue)
        let edit = await viewModel.handleEditPlaylist(songService: songService, playlist: playlista, filters: [filter])
        
        XCTAssertFalse(edit)
    }
    
    func testResetViewModelValues() async throws {
        viewModel.playlistName = "HELLOOOO"
        await viewModel.resetViewModelValues()
        
        XCTAssertTrue(viewModel.playlistName.isEmpty)
    }
    
    func testEditPlaylisLimitValues() async throws {
        playlista.name = "Elllo"
        playlista.limitType = LimitType.hours.rawValue
        playlista.limitSortType = LimitSortType.lastPlayed.rawValue
        let filter = Filter(type: FilterType.artist.rawValue, value: "Yeat", condition: Condition.equals.rawValue)
        await viewModel.assignViewModelValues(playlist: playlista, filters: [filter])
        let _ = await viewModel.handleEditPlaylist(songService: songService, playlist: playlista, filters: [filter])
        
        XCTAssertTrue(playlista.limit == 25)
        XCTAssertTrue(playlista.limitType == LimitType.hours.rawValue)
        XCTAssertTrue(playlista.limitSortType == LimitSortType.lastPlayed.rawValue)
    }
    
    func testAssignEditViewModelValues() async throws {
        playlista.name = "Shrek"
        playlista.liveUpdating = false
        playlista.matchRules = MatchRules.all.rawValue
        let dateString = Helpers().datePickerFormatter.string(from: Date())
        let filter = Filter(type: FilterType.artist.rawValue, value: "Yeat", condition: Condition.equals.rawValue)
        let filter1 = Filter(type: FilterType.dateAdded.rawValue, value: "", condition: Condition.equals.rawValue, date: dateString)
        playlista.filters = [filter.id.uuidString, filter1.id.uuidString]
        await viewModel.assignViewModelValues(playlist: playlista, filters: [filter, filter1])
        
        XCTAssertTrue(viewModel.playlistName == "Shrek")
        XCTAssertTrue(viewModel.liveUpdating == false)
        XCTAssertEqual(viewModel.playlistFilters?.count, 2)
        XCTAssertFalse(viewModel.filteredDates.isEmpty)
        XCTAssertTrue(viewModel.matchRules == MatchRules.all.rawValue)
    }
    
    func testEditPlaylistDates() async throws {
        playlista.name = "Ello"
        let dateString = "May 10, 2023"
        let filter = Filter(type: FilterType.dateAdded.rawValue, value: "", condition: Condition.equals.rawValue, date: dateString)
        await viewModel.assignViewModelValues(playlist: playlista, filters: [filter])
        playlista.filters = [filter.id.uuidString]
        
        let dateString1 = "Jan 20, 2023"
        let filter1 = Filter(type: FilterType.dateAdded.rawValue, value: "", condition: Condition.equals.rawValue, date: dateString1)
        await viewModel.assignViewModelValues(playlist: playlista, filters: [filter1])
        let newSongs = await songService.fetchMatchingSongIDs(dates: viewModel.filteredDates, filterrs: [filter1], limit: viewModel.limit, limitType: viewModel.limitSortType, limitSortType: viewModel.limitSortType, matchRules: viewModel.matchRules, smartRules: viewModel.smartRulesActive)
        let matchingSongs = songService.ogSongs.filter {
            newSongs.contains($0.id.rawValue)
        }
        let _ = await viewModel.handleEditPlaylist(songService: songService, playlist: playlista, filters: [filter1])
        
        XCTAssertEqual(filter1.id.uuidString, playlista.filters?.first)
        XCTAssertNotNil(matchingSongs.map {$0.libraryAddedDate == Helpers().dateFormatter.date(from: filter1.date ?? "")})
    }
}
