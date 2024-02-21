//
//  SongList.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/19/24.
//

import SwiftUI
import MusicKit

struct SongList: View {
    @Environment(SongService.self) var songService
    @State private var selectedFilter: String? = nil
    @State private var text: String = ""
    @Binding var filterActive: Bool
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    Circle()
                        .fill(.clear)
                        .frame(width: 44)
                }
                
                Spacer()
                
                Text("Desmond's Songs")
                    .foregroundStyle(.oreo.opacity(0.9))
                    .font(.title2.bold())
                    .fontDesign(.rounded)
                    .frame(maxWidth: .infinity)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(.oreo.opacity(0.9))
                        .frame(width: 44)
                        .shadow(radius: 5)
                    Image(systemName: "folder.fill.badge.gearshape")
                        .bold()
                        .foregroundStyle(.white)
                }
                .onTapGesture {
                    
                }
            }
            .padding(.top)
            .padding(.bottom, 8)
            .blur(radius: filterActive ? 5 : 0)
            
            TextField("", text: $text)
                .textFieldStyle(CustomTextFieldStyle(text: $text, placeholder: "Search for song", icon: "magnifyingglass"))
                .autocorrectionDisabled()
                .padding(.vertical, 8)
            ScrollView {
                VStack(alignment: .leading) {
                    headerItems
                    songList
                }
            }
            .scrollIndicators(.never)
            .disabled(filterActive)
            .blur(radius: filterActive ? 5 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }
    
    private var headerItems: some View {
        HStack {
            Text("RANK")
                .frame(width: 44)
            Spacer()
            Text("PLAYS")
            Image(systemName: "chevron.down")
                .bold()
        }
        .font(.subheadline.bold())
        .opacity(0.7)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
    private var songList: some View {
        LazyVStack {
            ForEach(songService.sortedSongs.enumerated().filter { !$0.element.artistName.isEmpty }, id: \.offset) { index, song in
                SongListRow(song: song, index: index)
            }
        }
    }
    private var filterStack: some View {
        HStack {
            Spacer()
            filterCapsule(title: "Sort Options", icon: "line.3.horizontal.decrease.circle")
            Spacer()
            filterCapsule(title: "Smart Filters", icon: "gear")
                .frame(maxWidth: .infinity)
            Spacer()
        }
        .padding(.vertical, 16)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func filterCapsule(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
            Text(title)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .foregroundStyle(selectedFilter == title ? .white : .naranja)
        .font(.headline)
        .bold()
        .frame(maxWidth: .infinity)
        .background(
            Capsule()
                .fill(selectedFilter == title ? .naranja.opacity(0.8) : .white)
                .stroke(.naranja, lineWidth: 2)
                .frame(height: 44)
        )
        .onTapGesture {
            withAnimation {
                self.selectedFilter = title
                songService.sortedSongs = songService.sortedSongs.map { $0 }.sorted { $0.title.lowercased() < $1.title.lowercased() }
            }
        }
    }
}

#Preview {
    SongList(filterActive: .constant(false))
        .environment(SongService())
//        .environment(AuthService())
}

struct SongListRow: View {
    let song: Song
    let index: Int
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    Image(systemName: "seal.fill")
                        .font(.title)
                        .foregroundStyle(index == 0 ? .naranja : .clear)
                    Text("\(index + 1)")
                        .fontWeight(.semibold)
                        .foregroundStyle(index == 0 ? .white : .primary)
                }
                .padding(.trailing, 8)
                
                if let artwork = song.artwork {
                    ArtworkImage(artwork, width: 44)
                        .clipShape(.rect(cornerRadius: 22, style: .continuous))
                        .shadow(radius: 5)
                } else {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .foregroundStyle(.gray.opacity(0.8))
                        .frame(width: 44, height: 44)
                }
                
                VStack(alignment: .leading) {
                    Text(song.title)
                        .fontWeight(.semibold)
                    Text(song.artistName)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 4)
                .lineLimit(1)
                
                Spacer()
                
                Text("\(song.playCount ?? 0)")
                    .fontWeight(.bold)
            }
            .frame(height: 55)
            
            RoundedRectangle(cornerRadius: 1)
                .frame(height: 1)
                .padding(.leading, UIScreen.main.bounds.width / 8)
                .foregroundStyle(.secondary.opacity(0.2))
        }
        .frame(maxWidth: .infinity)
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            Image(systemName: icon)
            ZStack {
                Text(placeholder)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(text.isEmpty ? 1.0 : 0)
                configuration
                    .foregroundStyle(.white)
            }
        }
        .bold()
        .foregroundStyle(.white)
        .padding(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.naranja)
                .shadow(color: .gray.opacity(0.4), radius: 2)
        )
    }
}
