//
//  SearchView.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/15/24.
//

import SwiftUI

struct SearchView: View {
    @Environment(SongService.self) var songService
    @Binding var moveSet: CGFloat
    
    var body: some View {
        @Bindable var service = songService
        
        VStack {
            Button {
                withAnimation(.bouncy) {
                    moveSet = .zero
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.oreo)
                        .frame(width: 44)
                        .shadow(radius: 5)
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                        .font(.title3)
                        .fontWeight(.heavy)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
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
            }
            
            Spacer()
        }
        .padding(24)
    }
    
    private func searchBox(_ text: Binding<String>) -> some View {
        VStack {
            TextField("", text: text)
                .textFieldStyle(CustomTextFieldStyle(text: text, icon: "magnifyingglass"))
        }
    }
}

#Preview {
    SearchView(moveSet: .constant(.zero))
        .environment(SongService())
}

struct CustomTextFieldStyle: TextFieldStyle {
    @Binding var text: String
    let icon: String
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            Image(systemName: icon)
            configuration
        }
        .bold()
        .foregroundStyle(.accent)
        .padding(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white)
//                .shadow(radius: 5)
        )
    }
}