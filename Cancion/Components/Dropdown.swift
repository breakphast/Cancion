//
//  DropDownView.swift
//  UIPractice
//
//  Created by Desmond Fitch on 12/5/23.
//

import SwiftUI

struct Dropdown: View {
    @Environment(SongService.self) var songService
    @State var filter: SongFilterModel = ArtistFilter(value: "", condition: .equals)
    var conditional: Bool?
    
    var options: [String]
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
            .background((type == .smartFilter ? Color.white : .oreo).shadow(.drop(color: .oreo.opacity(0.15), radius: 4)), in: .rect(cornerRadius: cornerRadius, style: .continuous))
            .frame(height: size.height, alignment: anchor == .top ? .bottom : .top)
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
                .foregroundStyle(selection == option ? Color.primary : (type == .smartFilter ? Color.gray : .white.opacity(0.8)))
                .fontWeight(selection == option ? .heavy : .regular)
                .animation(.none, value: selection)
                .frame(height: 40)
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation(.snappy) {
                        selection = option
                        showOptions = false
                        type == .smartFilter ? handleSmartFilters(option: option) : handleLimitFilters(option: option)
                    }
                }
            }
        }
        .padding(.horizontal, (type != .limitInt ? 8 : 4))
        .padding(.vertical, 5)
        .transition(.move(edge: anchor == .top ? .bottom : .top))
    }
    
    func handleSmartFilters(option: String) {
        songService.filters.enumerated().forEach { index, filterModel in
            if filterModel.id == filter.id {
                switch option {
                case FilterTitle.artist.rawValue:
                    songService.filters[index] = ArtistFilter(id: filterModel.id, value: "", condition: .equals)
                case FilterTitle.title.rawValue:
                    songService.filters[index] = TitleFilter(id: filterModel.id, value: "Queen Latifah", condition: .equals)
                case FilterTitle.playCount.rawValue:
                    songService.filters[index] = PlayCountFilter(id: filterModel.id, playCount: 0, condition: .greaterThan, value: "")
                case ConditionalTitle.doesNotContain.rawValue:
                    songService.filters[index].condition = .doesNotContain
                default:
                    print("No type found.")
                }
            }
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
    case limitInt
    case limit
}
