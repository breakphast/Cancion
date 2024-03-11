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
    
    var limitOptions: [String] {
        var limits = Limit.limits(forType: viewModel.genPlaylist.limitType).map { $0.value }
        return limits
    }
    
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
            
            Dropdown(options: limitOptions, selection: String(viewModel.genPlaylist.limit), type: .limit, playlist: viewModel.genPlaylist)
                .frame(width: 44, height: 44)
            Dropdown(options: ["items", "minutes", "hours"], selection: viewModel.genPlaylist.limitType, type: .limitType, playlist: viewModel.genPlaylist)
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
                Dropdown(options: LimitSortType.allCases.map {$0.rawValue}, selection: viewModel.genPlaylist.limitSortType, type: .limitSortType, playlist: viewModel.genPlaylist)
            }
            .foregroundStyle(.oreo)
        }
    }
}

//#Preview {
//    LimitToStack(filter: .constant(LimitFilter(active: true, limit: 25, limitTypeSelection: "items", limitSortSelection: "most played", condition: .equals)))
//}
