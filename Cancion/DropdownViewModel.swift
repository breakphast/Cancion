//
//  DropdownViewModel.swift
//  Cancion
//
//  Created by Desmond Fitch on 4/2/24.
//

import SwiftUI

@Observable class DropdownViewModel {
    var filter: Filter?
    var options = [String]()
    var type: DropdownType?
    var selection = ""
    var limit: Int?
    var limitType: String?
    var limitSortType: String?
    var matchRules: String?
    var dropdownActive = false
    var showOptions = false
    
    var limitOptions: [String] {
        return Limit.limits(forType: limitType ?? LimitType.items.rawValue).map { $0.value }
    }
    
    func handleSmartFilters(option: String) {
        guard let filter else { return }
        
        switch option {
        case FilterTitle.artist.rawValue:
            filter.type = FilterType.artist.rawValue
        case FilterTitle.title.rawValue:
            filter.type = FilterType.title.rawValue
        case FilterTitle.playCount.rawValue:
            filter.type = FilterType.plays.rawValue
        case FilterTitle.dateAdded.rawValue:
            filter.type = FilterType.dateAdded.rawValue
        case FilterTitle.lastPlayedDate.rawValue.capitalized:
            filter.type = FilterType.lastPlayedDate.rawValue
        default:
            print("No type found.")
        }
    }
    
    func assignViewModelValues(filter: Filter, matchRules: String, type: DropdownType, limit: Int?, limitType: String?, limitSortType: String?) {
        self.limit = limit
        self.limitType = limitType
        self.limitSortType = limitSortType
        self.filter = filter
        self.matchRules = matchRules
        self.type = type
        assignFilterOptionsAndSelection(filter: filter)
    }
    
    func handleSmartConditions(option: String) {
        guard let filter else { return }
        
        switch option {
        case Condition.equals.rawValue:
            filter.condition = Condition.equals.rawValue
        case Condition.contains.rawValue:
            filter.condition = Condition.contains.rawValue
        case Condition.doesNotContain.rawValue:
            filter.condition = Condition.doesNotContain.rawValue
        case Condition.greaterThan.rawValue:
            filter.condition = Condition.greaterThan.rawValue
        case Condition.lessThan.rawValue:
            filter.condition = Condition.lessThan.rawValue
        case Condition.before.rawValue:
            filter.condition = Condition.before.rawValue
        case Condition.after.rawValue:
            filter.condition = Condition.after.rawValue
        default:
            print("No type found.")
        }
    }
    
    func handleOptionSelected(selection: String) {
        dropdownActive = false
        self.selection = selection
        self.showOptions = false
        
        switch type {
        case .smartFilter:
            handleSmartFilters(option: selection)
        case .smartCondition:
            handleSmartConditions(option: selection)
        case .matchRules:
            if let rule = MatchRules(rawValue: selection) {
                self.matchRules = rule.rawValue
            }
        default:
            handleLimitFilters(option: selection)
        }
    }
    
    func assignFilterOptionsAndSelection(filter: Filter) {
        switch type {
        case .smartFilter:
            self.options = FilterType.allCases.map { $0.rawValue.capitalized }
            self.selection = filter.type.capitalized
            handleSmartFilters(option: filter.type)
        case .smartCondition:
            if let condition = Condition(rawValue: filter.condition) {
                switch filter.type {
                case FilterType.artist.rawValue, FilterType.title.rawValue:
                    self.options = [Condition.equals, Condition.contains, Condition.doesNotContain].map {$0.rawValue}
                    self.selection = condition.rawValue
                    handleSmartConditions(option: condition.rawValue)
                case FilterType.plays.rawValue:
                    self.options = [Condition.greaterThan, Condition.lessThan].map {$0.rawValue}
                    self.selection = condition.rawValue
                    handleSmartConditions(option: condition.rawValue)
                case FilterType.dateAdded.rawValue, FilterType.lastPlayedDate.rawValue:
                    self.options = [Condition.equals, Condition.before, Condition.after].map {$0.rawValue}
                    self.selection = condition.rawValue
                    handleSmartConditions(option: condition.rawValue)
                default:
                    return
                }
            }
        case .limit:
            self.selection = String(limit ?? 25)
            self.options = limitOptions
            handleLimitFilters(option: String(limit ?? 25))
        case .limitType:
            self.selection = limitType ?? LimitType.items.rawValue
            self.options = LimitType.allCases.map {$0.rawValue}
            handleLimitFilters(option: limitType ?? LimitType.items.rawValue)
        case .limitSortType:
            self.selection = limitSortType ?? LimitSortType.mostPlayed.rawValue
            self.options = LimitSortType.allCases.map {$0.rawValue}
            handleLimitFilters(option: limitSortType ?? LimitSortType.mostPlayed.rawValue)
        case .matchRules:
            self.options = ["all", "any"]
            self.selection = matchRules ?? MatchRules.any.rawValue
        default:
            return
        }
    }
    
    func handleLimitFilters(option: String) {
        if let limitType = LimitType(rawValue: option) {
            self.limitType = limitType.rawValue
        } else {
            let allLimits = LimitType.allCases.flatMap { Limit.limits(forType: $0.rawValue) }
            if let matchingLimit = allLimits.first(where: { $0.value == option }) {
                limit = Int(matchingLimit.value) ?? 0
            } else if let sortType = LimitSortType(rawValue: option) {
                limitSortType = sortType.rawValue
            } else {
                print("No matching type or value found")
            }
        }
    }
}
