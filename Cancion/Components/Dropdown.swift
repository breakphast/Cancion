//
//  DropDownView.swift
//  UIPractice
//
//  Created by Desmond Fitch on 12/5/23.
//

import SwiftUI

struct Dropdown: View {
    @Environment(SongService.self) var songService
    @Environment(PlaylistGeneratorViewModel.self) var playlistViewModel
    @State var filter = FilterModel()
    @State var options: [String] = []
    
    var limitOptions: [String] {
        let limits = Limit.limits(forType: playlistViewModel.genPlaylist.limitType).map { $0.value }
        return limits
    }
    
    var anchor: Anchor = .bottom
    var cornerRadius: CGFloat = 12
    
    @State var selection = ""
    @State private var showOptions = false
    @SceneStorage("dropDownZIndex") private var index = 1000.0
    @State private var zIndex: Double = 1000.0
    
    let type: DropdownType
    let playlist: Playlista
        
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack {
                if showOptions && anchor == .top {
                    optionsView()
                }
                
                SmartFilterComponent(title: $selection, type: type)
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
                        selection = option
                        showOptions = false
                        
                        switch type {
                        case .smartFilter:
                            handleSmartFilters(option: option)
                        case .smartCondition:
                            handleSmartConditions(option: option)
                        case .matchRules:
                            if let rule = MatchRules(rawValue: option) {
                                playlistViewModel.matchRules = rule
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
        playlistViewModel.activeFilters.enumerated().forEach { index, filterModel in
            if filterModel.id == filter.id {
                switch option {
                case FilterTitle.artist.rawValue:
                    playlistViewModel.activeFilters[index].type = FilterType.artist.rawValue
                case FilterTitle.title.rawValue:
                    playlistViewModel.activeFilters[index].type = FilterType.title.rawValue
                case FilterTitle.playCount.rawValue:
                    playlistViewModel.activeFilters[index].type = FilterType.plays.rawValue
                default:
                    print("No type found.")
                }
            }
        }
    }
    
    func handleSmartConditions(option: String) {
        playlistViewModel.activeFilters.enumerated().forEach { index, filterModel in
            if filterModel.id == filter.id {
                switch option {
                case Condition.equals.rawValue:
                    playlistViewModel.activeFilters[index].condition = Condition.equals.rawValue
                case Condition.contains.rawValue:
                    playlistViewModel.activeFilters[index].condition = Condition.contains.rawValue
                case Condition.doesNotContain.rawValue:
                    playlistViewModel.activeFilters[index].condition = Condition.doesNotContain.rawValue
                case Condition.greaterThan.rawValue:
                    playlistViewModel.activeFilters[index].condition = Condition.greaterThan.rawValue
                case Condition.lessThan.rawValue:
                    playlistViewModel.activeFilters[index].condition = Condition.lessThan.rawValue
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
            switch filter.type {
            case FilterType.artist.rawValue, FilterType.title.rawValue:
                self.options = [Condition.equals, Condition.contains, Condition.doesNotContain].map {$0.rawValue}
                self.selection = Condition.equals.rawValue
                handleSmartConditions(option: Condition.equals.rawValue)
            case FilterType.plays.rawValue:
                self.options = [Condition.greaterThan, Condition.lessThan].map {$0.rawValue}
                self.selection = Condition.greaterThan.rawValue
                handleSmartConditions(option: Condition.greaterThan.rawValue)
            default:
                return
            }
        case .matchRules:
            self.selection = "all"
        case .limit:
            self.selection = "25"
        case .limitType:
            self.selection = "items"
        case .limitSortType:
            self.selection = "most played"
        }
    }
    
    func handleLimitFilters(option: String) {
        switch option {
        case LimitType.items.rawValue:
            playlistViewModel.genPlaylist.limitType = "items"
            selection = "25"
        case LimitType.hours.rawValue:
            playlistViewModel.genPlaylist.limitType = "hours"
            selection = "1"
        case LimitType.minutes.rawValue:
            playlistViewModel.genPlaylist.limitType = "minutes"
            selection = "15"
        case "25", "100", "250", "500":
            if let limitValue = Int(option) {
                playlistViewModel.genPlaylist.limit = limitValue
            }
        default:
            if let sortType = LimitSortType(rawValue: option) {
                playlistViewModel.genPlaylist.limitSortType = sortType.rawValue
            } else {
                print("No type found.")
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
}
