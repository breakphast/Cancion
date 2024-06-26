//
//  DropDownView.swift
//  UIPractice
//
//  Created by Desmond Fitch on 12/5/23.
//

import SwiftUI
import SwiftData

struct Dropdown: View {
    // MARK: - Main State Properties
    @State var filter = Filter()
    @State var type: DropdownType
    @Binding var matchRules: String?
    @Binding var filters: [Filter]?
    @Binding var limit: Int?
    @Binding var limitType: String?
    @Binding var limitSortType: String?
    @Binding var dropdownActive: Bool
    
    // MARK: - UI Properties
    @SceneStorage("dropDownZIndex") private var index = 1000.0
    @State private var zIndex: Double = 1000.0
    var anchor: Anchor = .bottom
    var cornerRadius: CGFloat = 12
    
    @State private var dropdownViewModel = DropdownViewModel()
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            VStack {
                if dropdownViewModel.showOptions && anchor == .top {
                    optionsView()
                }
                SmartFilterComponent(title: $dropdownViewModel.selection, limit: dropdownViewModel.limit ?? 0, type: type)
                    .frame(width: size.width - 1, height: size.height)
                    .onTapGesture {
                        index += 100
                        zIndex = index
                        withAnimation {
                            dropdownViewModel.showOptions.toggle()
                            if type == .limitSortType || type == .limit {
                                dropdownActive.toggle()
                            }
                        }
                    }
                    .zIndex(10)
                
                if dropdownViewModel.showOptions && anchor == .bottom {
                    optionsView()
                }
            }
            .clipped()
            .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
            .background(((type == .smartFilter || type == .smartCondition) ? Color.white : .oreo).shadow(.drop(color: .oreo.opacity(0.15), radius: 4)), in: .rect(cornerRadius: cornerRadius, style: .continuous))
            .frame(height: size.height, alignment: anchor == .top ? .bottom : .top)
            .onChange(of: filter.type) { oldValue, newValue in
                dropdownViewModel.assignFilterOptionsAndSelection(filter: filter)
            }
            .onChange(of: dropdownViewModel.limit ?? 0, { oldValue, newValue in
                if type == .limit {
                    limit = newValue
                    dropdownViewModel.selection = String(newValue)
                }
            })
            .onChange(of: dropdownViewModel.limitOptions, { oldValue, newValue in
                if let value = dropdownViewModel.limitOptions.first, type == .limit {
                    dropdownViewModel.limit = Int(value)
                    dropdownViewModel.selection = value
                }
            })
            .onChange(of: dropdownViewModel.limitType, { _, newLimitType in
                limitType = newLimitType
            })
            .onChange(of: dropdownViewModel.limitSortType, { _, newLimitSortType in
                limitSortType = newLimitSortType
            })
            .onChange(of: limitType, { _, newLimit in
                dropdownViewModel.limitType = newLimit
            })
            .onChange(of: dropdownViewModel.matchRules, { _, newMatchRules in
                matchRules = newMatchRules
            })
            .task {
                dropdownViewModel.assignViewModelValues(filter: filter, matchRules: matchRules, type: type, limit: limit, limitType: limitType, limitSortType: limitSortType, dropdownActive: dropdownActive)
            }
        }
        .frame(height: 44)
        .zIndex(zIndex)
    }
    
    @ViewBuilder
    func optionsView() -> some View {
        VStack(spacing: 10) {
            ForEach((type != .limit ? dropdownViewModel.options : dropdownViewModel.limitOptions).filter({$0 != dropdownViewModel.selection}), id: \.self) { option in
                HStack() {
                    Text(option)
                        .lineLimit(2)
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    if type != .limit {
                        Spacer()
                    }
                }
                .foregroundStyle(dropdownViewModel.selection == option ? Color.primary : ((type == .smartFilter || type == .smartCondition) ? Color.gray : .white.opacity(0.8)))
                .fontWeight(dropdownViewModel.selection == option ? .heavy : .regular)
                .animation(.none, value: dropdownViewModel.selection)
                .frame(height: 40)
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation(.snappy) {
                        dropdownViewModel.handleOptionSelected(selection: option)
                    }
                }
            }
        }
        .padding(.horizontal, (type != .limit ? 8 : 4))
        .padding(.vertical, 5)
        .transition(.move(edge: anchor == .top ? .bottom : .top))
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
