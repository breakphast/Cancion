//
//  SongServiceTests.swift
//  CancionTests
//
//  Created by Desmond Fitch on 3/21/24.
//

import XCTest
import MusicKit
import SwiftUI
@testable import Cancion

final class SongServiceTests: XCTestCase {
    var authService: AuthService!
    var songService: SongService!
    
    override func setUpWithError() throws {
        authService = AuthService()
        songService = SongService()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetSongs() async throws {
        try await songService.smartFilterSongs(limit: 25, by: .playCount)
        XCTAssertNotNil(songService.sortedSongs)
    }
    
    func testSongsHavePlays() async throws {
        try await songService.smartFilterSongs(limit: 25, by: .playCount)
        XCTAssertNotNil(songService.sortedSongs.compactMap {$0.playCount})
    }
}
