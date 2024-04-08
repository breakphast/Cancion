//
//  DropDownView.swift
//  UIPractice
//
//  Created by Desmond Fitch on 12/5/23.
//

import SwiftUI

struct SortDropdown: View {
    @Environment(HomeViewModel.self) var homeViewModel
    @State var options: [String] = []
    var anchor: Anchor = .bottom
    var cornerRadius: CGFloat = 12
    
    @State var selection: String = SongSortOption.plays.rawValue
    @State private var showOptions = false
    @SceneStorage("dropDownZIndex") private var index = 1000.0
    @State private var zIndex: Double = 1000.0
        
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack {
                SmartFilterComponent(title: $selection, limit: 0, type: .songListSort)
                    .frame(width: size.width - 1, height: size.height)
                    .onTapGesture {
                        index += 100
                        zIndex = index
                        withAnimation {
                            showOptions.toggle()
                        }
                    }
                    .zIndex(10)
                
                if showOptions && anchor == .bottom {
                    optionsView
                }
            }
            .clipped()
            .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
            .background(.oreo, in: .rect(cornerRadius: cornerRadius, style: .continuous))
            .frame(height: size.height, alignment: anchor == .top ? .bottom : .top)
        }
        .zIndex(zIndex)
    }
    
    var optionsView: some View {
        VStack(spacing: 8) {
            ForEach(options.filter({$0 != selection}), id: \.self) { option in
                Text(option)
                    .lineLimit(1)
                    .foregroundStyle(.white)
                    .font(.caption.bold())
                    .animation(.none, value: selection)
                    .padding(.leading, 4)
                    .frame(height: 40)
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.snappy) {
                            selection = option
                            if let sortOption = SongSortOption(rawValue: selection) {
                                homeViewModel.songSort = sortOption
                            }
                            showOptions = false
                        }
                }
            }
        }
        .padding(.vertical, 5)
        .transition(.move(edge: anchor == .top ? .bottom : .top))
    }
    
    enum Anchor {
        case top
        case bottom
    }
}
