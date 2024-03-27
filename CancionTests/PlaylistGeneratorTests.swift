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
        authService = AuthService()
        viewModel = PlaylistGeneratorViewModel()
        songService = SongService()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchMatchingSongsUsingArtistName() async throws {
        try await songService.smartFilterSongs(limit: 2000, by: .playCount) 
        let filter = FilterModel(type: FilterType.artist.rawValue, value: "Yeat", condition: Condition.equals.rawValue)
        
        let songIDs = await viewModel.fetchMatchingSongIDs(songs: songService.sortedSongs, filters: [filter], matchRules: "all", limitType: LimitType.items.rawValue)
        let actualSongs = songService.sortedSongs.filter { songIDs.contains($0.id.rawValue) }
        let nonMatching = actualSongs.filter { $0.artistName != "Yeat" }
        
        XCTAssertTrue(nonMatching.isEmpty)
    }
}
