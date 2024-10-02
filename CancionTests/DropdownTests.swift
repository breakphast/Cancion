//
//  DropdownTests.swift
//  CancionTests
//
//  Created by Desmond Fitch on 4/2/24.
//

import XCTest
import MusicKit
import SwiftUI
@testable import Cancion

final class DropdownTests: XCTestCase {
    var authService: AuthService!
    var viewModel: DropdownViewModel!
    var songService: SongService!
    var playlista: Playlistt!
    
    override func setUpWithError() throws {
        super.setUp()

        authService = AuthService()
        viewModel = DropdownViewModel()
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

    func testHandleSmartFiltersArtist() async throws {
        let filter = Filter(value: "Yeat")
        viewModel.filter = filter
        
        viewModel.handleSmartFilters(option: FilterTitle.title.rawValue)
        XCTAssertTrue(viewModel.filter?.type == FilterType.title.rawValue)
    }
    
    func testHandleSmartFiltersPlayCount() async throws {
        let filter = Filter(value: "Yeat")
        viewModel.filter = filter
        
        viewModel.handleSmartFilters(option: FilterTitle.playCount.rawValue)
        
        XCTAssertTrue(viewModel.filter?.type == FilterType.plays.rawValue, "Filter type should be set to plays")
    }
    
    func testHandleSmartFiltersDateAdded() async throws {
        let filter = Filter(value: "Yeat")
        viewModel.filter = filter
        
        viewModel.handleSmartFilters(option: FilterTitle.dateAdded.rawValue)
        
        XCTAssertTrue(viewModel.filter?.type == FilterType.dateAdded.rawValue, "Filter type should be set to dateAdded")
    }

    func testHandleSmartFiltersLastPlayedDate() async throws {
        let filter = Filter(value: "Yeat")
        viewModel.filter = filter
        
        viewModel.handleSmartFilters(option: FilterTitle.lastPlayedDate.rawValue)
        
        XCTAssertTrue(viewModel.filter?.type == FilterType.lastPlayedDate.rawValue, "Filter type should be set to lastPlayed")
    }
    
    func testAssignViewModelValues() async throws {
        let filter = Filter(type: FilterType.artist.rawValue, value: "Playboi Carti", condition: Condition.contains.rawValue)
        
        viewModel.assignViewModelValues(filter: filter, matchRules: MatchRules.any.rawValue, type: DropdownType.smartCondition, limit: nil, limitType: nil, limitSortType: nil, dropdownActive: false)
        
        XCTAssertTrue(viewModel.filter?.condition == Condition.contains.rawValue)
    }
    
    func testHandleSmartConditionsIs() async throws {
        let filter = Filter(value: "Yeat")
        viewModel.filter = filter
        
        viewModel.handleSmartConditions(option: Condition.equals.rawValue)
        
        XCTAssertTrue(viewModel.filter?.condition == Condition.equals.rawValue, "Filter condition should be set to equals")
    }
    
    func testHandleSmartConditionsContains() async throws {
        let filter = Filter(value: "Rock")
        viewModel.filter = filter
        
        viewModel.handleSmartConditions(option: Condition.contains.rawValue)
        
        XCTAssertTrue(viewModel.filter?.condition == Condition.contains.rawValue, "Filter condition should be set to contains")
    }
    
    func testHandleSmartConditionsDoesNotContain() async throws {
        let filter = Filter(value: "Pop")
        viewModel.filter = filter
        
        viewModel.handleSmartConditions(option: Condition.doesNotContain.rawValue)
        
        XCTAssertTrue(viewModel.filter?.condition == Condition.doesNotContain.rawValue, "Filter condition should be set to does not contain")
    }
    
    func testHandleSmartConditionsGreaterThan() async throws {
        let filter = Filter(value: "1000")
        viewModel.filter = filter
        
        viewModel.handleSmartConditions(option: Condition.greaterThan.rawValue)
        
        XCTAssertTrue(viewModel.filter?.condition == Condition.greaterThan.rawValue, "Filter condition should be set to greater than")
    }

    func testHandleSmartConditionsLessThan() async throws {
        let filter = Filter(value: "500")
        viewModel.filter = filter
        
        viewModel.handleSmartConditions(option: Condition.lessThan.rawValue)
        
        XCTAssertTrue(viewModel.filter?.condition == Condition.lessThan.rawValue, "Filter condition should be set to less than")
    }
    
    func testHandleSmartConditionsIsBefore() async throws {
        let filter = Filter(value: "2022-01-01")
        viewModel.filter = filter
        
        viewModel.handleSmartConditions(option: Condition.before.rawValue)
        
        XCTAssertTrue(viewModel.filter?.condition == Condition.before.rawValue, "Filter condition should be set to before")
    }
    
    func testHandleSmartConditionsIsAfter() async throws {
        let filter = Filter(value: "2022-12-31")
        viewModel.filter = filter
        
        viewModel.handleSmartConditions(option: Condition.after.rawValue)
        
        XCTAssertTrue(viewModel.filter?.condition == Condition.after.rawValue, "Filter condition should be set to after")
    }

    func testHandleLimitFilters() async throws {
        viewModel.handleLimitFilters(option: LimitSortType.mostPlayed.rawValue)
        
        XCTAssertNotNil(viewModel.limitSortType)
    }
    
    func testHandleOptionSelectedSmartFilter() async throws {
        viewModel.type = DropdownType.smartFilter
        let filter = Filter(value: "2022-12-31")
        viewModel.filter = filter
        viewModel.handleOptionSelected(selection: FilterTitle.title.rawValue)
        XCTAssertTrue(viewModel.filter?.type == FilterTitle.title.rawValue.lowercased())
    }
    
    func testHandleOptionSelectedSmartConditionContains() async throws {
        viewModel.type = DropdownType.smartCondition
        let filter = Filter(value: "Pop")
        viewModel.filter = filter
        viewModel.handleOptionSelected(selection: Condition.contains.rawValue)
        XCTAssertTrue(viewModel.filter?.condition == Condition.contains.rawValue, "Filter condition should be set to 'contains'")
    }
    
    func testHandleOptionSelectedMatchRulesSpecificRule() async throws {
        viewModel.type = DropdownType.matchRules
        let matchRule = MatchRules.all
        viewModel.handleOptionSelected(selection: matchRule.rawValue)
        XCTAssertTrue(viewModel.matchRules == matchRule.rawValue, "Match rule should be set to the specific rule")
    }
    
    func testHandleOptionSelectedInvalidSelection() async throws {
        viewModel.type = DropdownType.smartFilter
        let filter = Filter(value: "2022-12-31")
        viewModel.filter = filter
        viewModel.handleOptionSelected(selection: "titlee")
        XCTAssertFalse(viewModel.filter?.type == FilterTitle.title.rawValue.lowercased())
    }
}
