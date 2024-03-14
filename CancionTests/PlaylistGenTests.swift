//
//  PlaylistGenTests.swift
//  CancionTests
//
//  Created by Desmond Fitch on 3/14/24.
//

import XCTest
import MusicKit
@testable import Cancion

final class PlaylistGenTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGeneration() throws {
        let playlist = Playlista()
        
        XCTAssertTrue(playlist.limit == 25)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
