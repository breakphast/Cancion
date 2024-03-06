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
    var anchor: Anchor = .bottom
    var cornerRadius: CGFloat = 12
    
    @State var selection = ""
    @State private var showOptions = false
    @SceneStorage("dropDownZIndex") private var index = 1000.0
    @State private var zIndex: Double = 1000.0
    
    let type: DropdownType
        
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
            ForEach(options.filter({$0 != selection}), id: \.self) { option in
                HStack() {
                    Text(option)
                        .lineLimit(2)
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    if type != .limitInt {
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
                        case .limitInt, .limit:
                            handleLimitFilters(option: option)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, (type != .limitInt ? 8 : 4))
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
            self.options = ["all", "any"]
            self.selection = "all"
        case .limitInt:
            self.options = ["25", "50", "75"]
            self.selection = "25"
        case .limit:
            self.options = ["items", "other"]
            self.selection = "items"
        }
    }
    
    func handleLimitFilters(option: String) {
        switch option {
        case "items":
            songService.limitFilter.limitTypeSelection = "items"
        case "most played":
            songService.limitFilter.limitTypeSelection = "most played"
        case "50":
            songService.limitFilter.limit = "50"
        case "75":
            songService.limitFilter.limit = "75"
        default:
            print("No type found.")
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
    case limitInt
    case limit
}
