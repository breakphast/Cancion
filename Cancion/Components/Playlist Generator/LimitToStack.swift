//
//  LimitToStack.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/21/24.
//

import SwiftUI

struct LimitToStack: View {
    @Environment(SongService.self) var songService
    @Environment(PlaylistGeneratorViewModel.self) var viewModel
    @State var selected = false
    @State var limitTypeSelection = "items"
    @State var limitSortSelection = "sorted by"
    @Binding var filters: [Filter]?
    @Binding var limit: Int?
    @Binding var limitType: String?
    @Binding var limitSortType: String?
    @Binding var matchRules: String?
    @Binding var dropdownActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                checkbox
                limitToStack
            }
            .zIndex(10)
            selectedByStack
                .zIndex(1)
        }
    }
    
    private var checkbox: some View {
        Button {
            withAnimation {
                viewModel.limitActive.toggle()
            }
        } label: {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(viewModel.limitActive ? .naranja.opacity(0.9) : .white)
                .shadow(radius: 2)
                .frame(width: 33, height: 33)
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundStyle(.white)
                }
        }
    }
    
    private var limitToStack: some View {
        HStack {
            Text("Limit to")
                .fontWeight(.semibold)
                .font(.title3)
            
            if let _ = self.filters {
                Dropdown(type: .limit, matchRules: $matchRules, filters: $filters, limit: $limit, limitType: $limitType, limitSortType: $limitSortType, dropdownActive: $dropdownActive)
                    .frame(width: 44, height: 44)
                Dropdown(type: .limitType, matchRules: $matchRules, filters: $filters, limit: $limit, limitType: $limitType, limitSortType: $limitSortType, dropdownActive: $dropdownActive)
            }
        }
        .foregroundStyle(.oreo)
    }
    
    private var selectedByStack: some View {
        HStack {
            Rectangle()
                .fill(.clear)
                .frame(width: 33, height: 33)
            HStack {
                Text("sorted by")
                    .fontWeight(.semibold)
                    .font(.title3)
                if let _ = self.filters {
                    Dropdown(type: .limitSortType, matchRules: $matchRules, filters: $filters, limit: $limit, limitType: $limitType, limitSortType: $limitSortType, dropdownActive: $dropdownActive)
                }
            }
            .foregroundStyle(.oreo)
        }
    }
}

//#Preview {
//    LimitToStack(filter: .constant(LimitFilter(active: true, limit: 25, limitTypeSelection: "items", limitSortSelection: "most played", condition: .equals)))
//}
