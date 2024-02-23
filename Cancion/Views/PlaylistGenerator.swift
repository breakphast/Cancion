//
//  PlaylistGenerator.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/20/24.
//

import SwiftUI

struct PlaylistGenerator: View {
    @State var filters = [
        FilterModel(text: "", filterTitle: "Artist", conditionalTitle: "is"),
    ]
    @Binding var moveSet: CGFloat
    @State private var playlistName = ""
    @State private var smartRulesActive = true
    
    var body: some View {
        ZStack {
            VStack {
                headerTitle
                    .fontDesign(.rounded)
                    .padding(.horizontal, 12)
                ScrollView {
                    VStack {
                        playlistCover
                            .padding(.top, 16)
                        playlistTitle
                            .padding(.top, 24)
                        
                            VStack(alignment: .leading) {
                                VStack(alignment: .leading, spacing: 16) {
                                    FilterCheckbox(title: "Smart Rules", icon: "questionmark.circle.fill", cornerRadius: 12, strokeColor: .oreo, smartRules: $smartRulesActive)
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        ForEach(filters.indices, id: \.self) { index in
                                            SmartFilterStack(text: $filters[index].text, filters: $filters, filterTitle: filters[index].filterTitle, conditionalTitle: filters[index].conditionalTitle)
                                        }
                                        .blur(radius: !smartRulesActive ? 0 : 2)
                                        addFilterButton
                                            .blur(radius: !smartRulesActive ? 0 : 2)
                                        
                                        RoundedRectangle(cornerRadius: 1)
                                            .frame(height: 1)
                                            .padding(.horizontal)
                                            .padding(.vertical, 12)
                                            .foregroundStyle(.secondary.opacity(0.2))
                                    }
                                }
                                
                                LimitToStack(limit: 24)
                                
                                RoundedRectangle(cornerRadius: 1)
                                    .frame(height: 1)
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                                    .foregroundStyle(.secondary.opacity(0.2))
                                
                                FilterCheckbox(title: "Live updating", icon: nil, cornerRadius: 12, strokeColor: .oreo, smartRules: $smartRulesActive)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top)
                    }
                }
                .scrollIndicators(.never)
                .safeAreaPadding(.bottom, 24)
            }
            .padding(.top)
        }
    }
    
    private func calculateScrollViewHeight() -> CGFloat {
        let filterHeight: CGFloat = 48 + 64
        let spacing: CGFloat = 8
        let totalHeight = CGFloat(filters.count) * filterHeight + CGFloat(filters.count - 1) * spacing
        print(UIScreen.main.bounds.height)
        return min(totalHeight, UIScreen.main.bounds.height * 0.25)
    }
    
    private var playlistCover: some View {
        Image(.osama)
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .frame(maxWidth: .infinity)
            .shadow(radius: 2)
            .padding(.horizontal, 24)
    }
    
    private var headerTitle: some View {
        ZStack {
            Text("Playlist Generator")
                .foregroundStyle(.oreo.opacity(0.9))
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .center)
            
            Button {
                withAnimation(.bouncy(duration: 0.4)) {
                    moveSet += UIScreen.main.bounds.width
                }
            } label: {
                Image(systemName: "checkmark")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
                    .background(
                        Circle()
                            .fill(.oreo.opacity(0.9))
                            .shadow(radius: 2)
                    )
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .tint(.white)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var playlistTitle: some View {
        VStack(alignment: .center, spacing: 8) {
            TextField("Playlist Name", text: $playlistName)
                .foregroundStyle(.oreo)
                .font(.title.bold())
                .lineLimit(1)
                .padding(.horizontal, 24)
                .autocorrectionDisabled()
                
            RoundedRectangle(cornerRadius: 2)
                .frame(height: 1)
                .foregroundStyle(.gray.opacity(0.2))
                .padding(.horizontal, 24)
        }
    }
    
    private var addFilterButton: some View {
        Button {
            withAnimation {
                filters.append(FilterModel(text: "", filterTitle: "Title", conditionalTitle: "does not contain"))
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.oreo.opacity(0.9))
                    .shadow(radius: 2)
                    .frame(width: 44, height: 44)
                Image(systemName: "plus")
                    .foregroundStyle(.white)
                    .fontWeight(.black)
            }
        }
    }
    
}

#Preview {
    PlaylistGenerator(moveSet: .constant(.zero))
}
