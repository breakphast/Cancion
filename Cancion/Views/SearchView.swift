//
//  SearchView.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/15/24.
//

import SwiftUI

struct SearchView: View {
    @Environment(SongService.self) var songService
    
    var body: some View {
        @Bindable var service = songService
        
        VStack {
            searchBox($service.searchTerm)
            if !songService.searchResultSongs.isEmpty {
                List(songService.searchResultSongs) { song in
                    Text(song.title)
                        .onTapGesture {
                            Task {
                                try await songService.fetchSong(id: song.id.rawValue)
                                songService.searchActive = false
                            }
                        }
                }
            } else {
                Text("No favorite song set")
                    .font(.title.bold())
                    .frame(maxHeight: .infinity, alignment: .center)
            }
        }
    }
    
    private func searchBox(_ text: Binding<String>) -> some View {
        VStack {
            TextField("", text: text)
                .textFieldStyle(CustomTextFieldStyle(song: text))
        }
    }
}

#Preview {
    SearchView()
        .environment(SongService())
}

struct CustomTextFieldStyle: TextFieldStyle {
    @Binding var song: String
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
            configuration
        }
        .bold()
        .foregroundStyle(.white)
        .padding(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.oreo)
        )
        .padding(.horizontal)
        .padding(.leading, 56)
    }
}
