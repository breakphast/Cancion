//
//  PlaylistGenerator.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/20/24.
//

import SwiftUI

struct PlaylistGenerator: View {
    @State var filters = [
        Filter(text: "Lil Uzi Vert", filterTitle: "Artist", conditionalTitle: "is"),
//        Filter(text: "", filterTitle: "Title", conditionalTitle: "does not contain"),
//        Filter(text: "", filterTitle: "Date", conditionalTitle: "is before")
    ]
    
    var body: some View {
        ZStack {
            VStack {
                headerTitle
                VStack {
                    playlistCover
                    playlistTitle
                        .padding(12)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 40) {
                            VStack(alignment: .leading, spacing: 16) {
                                FilterCheckbox(title: "Smart Rules", icon: "questionmark.circle.fill", cornerRadius: 8, strokeColor: .naranja)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(filters.indices, id: \.self) { index in
                                        SmartFilterStack(text: $filters[index].text, filters: $filters, filterTitle: filters[index].filterTitle, conditionalTitle: filters[index].conditionalTitle)
                                    }
                                    addFilterButton
                                }
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(.white)
//                                        .shadow(radius: 5)
                                )
                            }
                            
                            LimitToStack(limit: 24)
                            FilterCheckbox(title: "Live updating", icon: nil, cornerRadius: 8, strokeColor: .naranja, selected: true)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }
                    .scrollIndicators(.never)
                    
                    Spacer()
                    doneButton
                }
            }
        }
        .fontDesign(.rounded)
    }
    
    private func calculateScrollViewHeight() -> CGFloat {
        let filterHeight: CGFloat = 48 + 64 // Assuming each filter stack has a height of 44
        let spacing: CGFloat = 8 // Spacing between filters
        let totalHeight = CGFloat(filters.count) * filterHeight + CGFloat(filters.count - 1) * spacing
        print(UIScreen.main.bounds.height)
        return min(totalHeight, UIScreen.main.bounds.height * 0.25)
    }
    
    private var playlistCover: some View {
        Image(.osama)
            .resizable()
            .scaledToFill()
            .frame(height: 150)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .frame(maxWidth: .infinity)
            .shadow(radius: 5)
            .overlay {
                Image(systemName: "camera")
                    .padding(16)
                    .foregroundStyle(.naranja)
                    .background(.ultraThinMaterial)
                    .fontWeight(.heavy)
                    .clipShape(.circle)
            }
            .padding(.horizontal, 24)
    }
    
    private var headerTitle: some View {
        Text("Playlist Generator")
            .foregroundStyle(.oreo)
            .font(.title3.bold())
            .padding(.vertical)
    }
    
    private var playlistTitle: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Osamason Most Played")
                .foregroundStyle(.oreo)
                .font(.title.bold())
            
            RoundedRectangle(cornerRadius: 2)
                .frame(height: 1)
                .foregroundStyle(.gray.opacity(0.2))
                .padding(.horizontal, 24)
        }
    }
    
    private var addFilterButton: some View {
        Button {
            withAnimation {
                filters.append(Filter(text: "", filterTitle: "Title", conditionalTitle: "does not contain"))
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.naranja)
                    .frame(width: 44, height: 44)
                    .shadow(radius: 2)
                Image(systemName: "plus")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .fontWeight(.black)
            }
        }
    }
    
    private var doneButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.naranja)
                .frame(height: 44)
                .padding(.horizontal, 24)
            Text("DONE")
                .fontWeight(.heavy)
                .kerning(1.3)
                .padding()
                .foregroundStyle(.white)
        }
    }
}

struct Filter {
    var id = UUID()
    var text: String
    var filterTitle: String
    var conditionalTitle: String
}

struct SmartFilterStack: View {
    @Binding var text: String
    @Binding var filters: [Filter]
    @State var filterLocked = false
    var filterTitle: String
    var conditionalTitle: String
    
    var body: some View {
        ZStack {
            HStack {
                SmartFilterComponent(title: filterTitle)
                SmartFilterComponent(title: conditionalTitle)
                SmartFilterTextField(text: $text, filterLocked: $filterLocked)
                addFilterButton
            }
        }
    }
    
    private var addFilterButton: some View {
        HStack(spacing: 4) {
            if !filterLocked {
                Button {
                    withAnimation(.bouncy) {
                        filterLocked = true
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.naranja)
                            .shadow(radius: 2)
                        Image(systemName: filterLocked ? "minus" : "plus")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .fontWeight(.black)
                    }
                    .frame(width: 22, height: 33)
                }
            }
            
            Button {
                withAnimation(.bouncy) {
                    filters.removeLast(1)
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.naranja)
                        .shadow(radius: 2)
                    Image(systemName: "minus")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .fontWeight(.black)
                }
                .frame(width: 22, height: 33)
            }
        }
    }
}

#Preview {
    PlaylistGenerator()
}
