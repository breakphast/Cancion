//
//  DropDownView.swift
//  UIPractice
//
//  Created by Desmond Fitch on 12/5/23.
//

import SwiftUI

struct Dropdown: View {
    @Environment(PlaylistGeneratorViewModel.self) var playlistViewModel
    // MARK: - Main State Properties
    @State var filter = FilterModel()
    @State var options: [String] = []
    @State var selection = ""
    @State var type: DropdownType
    
    // MARK: - UI Properties
    @SceneStorage("dropDownZIndex") private var index = 1000.0
    @State private var zIndex: Double = 1000.0
    @State private var showOptions = false
    var anchor: Anchor = .bottom
    var cornerRadius: CGFloat = 12
    
    var limitOptions: [String] {
        let limits = Limit.limits(forType: playlistViewModel.limitType ?? LimitType.items.rawValue).map { $0.value }
        return limits
    }
        
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack {
                if showOptions && anchor == .top {
                    optionsView()
                }
                
                SmartFilterComponent(title: $selection, limit: playlistViewModel.limit ?? 0, type: type)
                    .frame(width: size.width - 1, height: size.height)
                    .onTapGesture {
                        index += 100
                        zIndex = index
                        withAnimation(.bouncy) {
                            showOptions.toggle()
                            if type == .limitSortType {
                                playlistViewModel.dropdownActive.toggle()
                            }
                        }
                    }
                    .zIndex(10)
                
                if showOptions && anchor == .bottom {
                    optionsView()
                }
            }
            .clipped()
            .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
            .background(((type == .smartFilter || type == .smartCondition) ? Color.white : .oreo).shadow(.drop(color: .oreo.opacity(0.15), radius: 4)), in: .rect(cornerRadius: cornerRadius, style: .continuous))
            .frame(height: size.height, alignment: anchor == .top ? .bottom : .top)
            .onChange(of: filter.type) { oldValue, newValue in
                handleFilterType(filter: filter)
            }
            .onChange(of: playlistViewModel.limit ?? 0, { oldValue, newValue in
                if type == .limit {
                    selection = String(newValue)
                }
            })
            .task {
                handleFilterType(filter: filter)
            }
        }
        .frame(height: 44)
        .zIndex(zIndex)
    }
    
    @ViewBuilder
    func optionsView() -> some View {
        VStack(spacing: 10) {
            ForEach((type != .limit ? options : limitOptions).filter({$0 != selection}), id: \.self) { option in
                HStack() {
                    Text(option)
                        .lineLimit(2)
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    if type != .limit {
                        Spacer()
                    }
                }
                .foregroundStyle(selection == option ? Color.primary : ((type == .smartFilter || type == .smartCondition) ? Color.gray : .white.opacity(0.8)))
                .fontWeight(selection == option ? .heavy : .regular)
                .animation(.none, value: selection)
                .frame(height: 40)
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation(.snappy) {
                        playlistViewModel.dropdownActive = false
                        selection = option
                        showOptions = false
                        
                        switch type {
                        case .smartFilter:
                            handleSmartFilters(option: option)
                        case .smartCondition:
                            handleSmartConditions(option: option)
                        case .matchRules:
                            if let rule = MatchRules(rawValue: option) {
                                playlistViewModel.matchRules = rule.rawValue
                            }
                        default:
                            handleLimitFilters(option: option)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, (type != .limit ? 8 : 4))
        .padding(.vertical, 5)
        .transition(.move(edge: anchor == .top ? .bottom : .top))
    }
    
    func handleSmartFilters(option: String) {
        playlistViewModel.filters.enumerated().forEach { index, filterModel in
            if filterModel.id == filter.id {
                switch option {
                case FilterTitle.artist.rawValue:
                    playlistViewModel.filters[index].type = FilterType.artist.rawValue
                case FilterTitle.title.rawValue:
                    playlistViewModel.filters[index].type = FilterType.title.rawValue
                case FilterTitle.playCount.rawValue:
                    playlistViewModel.filters[index].type = FilterType.plays.rawValue
                case FilterTitle.dateAdded.rawValue:
                    playlistViewModel.filters[index].type = FilterType.dateAdded.rawValue
                case FilterTitle.lastPlayedDate.rawValue.capitalized:
                    playlistViewModel.filters[index].type = FilterType.lastPlayedDate.rawValue
                default:
                    print("No type found.")
                }
            }
        }
    }
    
    func handleSmartConditions(option: String) {
        playlistViewModel.filters.enumerated().forEach { index, filterModel in
            if filterModel.id == filter.id {
                switch option {
                case Condition.equals.rawValue:
                    playlistViewModel.filters[index].condition = Condition.equals.rawValue
                case Condition.contains.rawValue:
                    playlistViewModel.filters[index].condition = Condition.contains.rawValue
                case Condition.doesNotContain.rawValue:
                    playlistViewModel.filters[index].condition = Condition.doesNotContain.rawValue
                case Condition.greaterThan.rawValue:
                    playlistViewModel.filters[index].condition = Condition.greaterThan.rawValue
                case Condition.lessThan.rawValue:
                    playlistViewModel.filters[index].condition = Condition.lessThan.rawValue
                case Condition.before.rawValue:
                    playlistViewModel.filters[index].condition = Condition.before.rawValue
                case Condition.after.rawValue:
                    playlistViewModel.filters[index].condition = Condition.after.rawValue
                default:
                    print("No type found.")
                }
            } else {
                
            }
        }
    }
    
    func handleFilterType(filter: FilterModel) {
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
                    self.selection = Condition.greaterThan.rawValue
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
            if let limit = playlistViewModel.limit {
                self.selection = String(limit)
                handleLimitFilters(option: String(limit))
            }
        case .limitType:
            if let limitType = playlistViewModel.limitType {
                self.selection = limitType
                handleLimitFilters(option: limitType)
            }
        case .limitSortType:
            if let limitSortType = playlistViewModel.limitSortType {
                self.selection = limitSortType
                handleLimitFilters(option: limitSortType)
            }
        default:
            return
        }
    }
    
    func handleLimitFilters(option: String) {
        if let limitType = LimitType(rawValue: option) {
            let defaultLimitValue = Limit.limits(forType: option).first?.value ?? "0"
            playlistViewModel.limitType = limitType.rawValue
            playlistViewModel.limit = Int(defaultLimitValue) ?? 0
        } else {
            let allLimits = LimitType.allCases.flatMap { Limit.limits(forType: $0.rawValue) }
            if let matchingLimit = allLimits.first(where: { $0.value == option }) {
                playlistViewModel.limit = Int(matchingLimit.value) ?? 0
            } else if let sortType = LimitSortType(rawValue: option) {
                playlistViewModel.limitSortType = sortType.rawValue
            } else {
                print("No matching type or value found")
            }
        }
    }
    
    enum Anchor {
        case top
        case bottom
    }
}

enum DropdownType {
    case smartFilter
    case smartCondition
    case matchRules
    case limit
    case limitType
    case limitSortType
    case songListSort
}
