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
    
    let playlist: Playlista
    
    var limitOptions: [String] {
        var limits = Limit.limits(forType: playlist.limitType).map { $0.value }
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
            
            Dropdown(options: limitOptions, selection: String(playlist.limit), type: .limit, playlist: playlist)
                .frame(width: 44, height: 44)
            Dropdown(options: ["items", "minutes", "hours"], selection: playlist.limitType, type: .limitType, playlist: playlist)
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
                Dropdown(options: LimitSortType.allCases.map {$0.rawValue}, selection: playlist.limitSortType, type: .limitSortType, playlist: playlist)
            }
            .foregroundStyle(.oreo)
        }
    }
}

//#Preview {
//    LimitToStack(filter: .constant(LimitFilter(active: true, limit: 25, limitTypeSelection: "items", limitSortSelection: "most played", condition: .equals)))
//}
