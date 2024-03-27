//
//  AuthorizationTests.swift
//  CancionTests
//
//  Created by Desmond Fitch on 3/21/24.
//

import XCTest
import MusicKit
import SwiftUI
@testable import Cancion

final class AuthorizationTests: XCTestCase {
    var authService: AuthService!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        authService = AuthService()
        authService.status = .notDetermined
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSuccessfulAuthorization() throws {
        let status = authService.status
        XCTAssertTrue(status == .notDetermined)
    }
}
