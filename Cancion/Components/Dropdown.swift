//
//  DropDownView.swift
//  UIPractice
//
//  Created by Desmond Fitch on 12/5/23.
//

import SwiftUI

struct Dropdown: View {
    var hint: String
    var options: [String]
    var anchor: Anchor = .bottom
    var cornerRadius: CGFloat = 24
    let filter: Bool
    @Binding var selection: String?
    @State private var showOptions = false
    @SceneStorage("dropDownZIndex") private var index = 1000.0
    @State private var zIndex: Double = 1000.0
    
    @State private var artist: String = ""
    @Binding var filterActive: Bool
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack {
                if showOptions && anchor == .top {
                    optionsView()
                }
                
                HStack(spacing: 0) {
                    Text(selection ?? hint)
                        .lineLimit(1)
                    
                    Spacer(minLength: 0)
                    
                    Image(systemName: "gear")
                        .font(.title3)
                        .rotationEffect(.degrees(showOptions ? -180.0 : 0))
                }
                .fontWeight(.heavy)
                .foregroundStyle(.white)
                .padding(.horizontal, 15)
                .frame(width: size.width - 1, height: size.height)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.accent)
//                        .stroke(.accent, lineWidth: 3)
                        .frame(height: 44)
                )
                .onTapGesture {
                    index += 1
                    zIndex = index
                    withAnimation(.bouncy) {
                        filterActive.toggle()
//                        if showOptions {
//                            selection = options.first ?? ""
//                        }
                        showOptions.toggle()
                    }
                }
                .zIndex(10)
                
                if showOptions && anchor == .bottom {
                    optionsView()
                }
            }
            .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
            .contentShape(.rect(cornerRadius: cornerRadius, style: .continuous))
            .background(.accent.shadow(.drop(color: .primary.opacity(0.15), radius: 4)), in: .rect(cornerRadius: cornerRadius, style: .continuous))
            .frame(height: size.height, alignment: anchor == .top ? .bottom : .top)
            .shadow(color: .gray.opacity(filterActive ? 0.0 : 0.1), radius: 7)
        }
        .frame(height: 44)
        .zIndex(zIndex)
    }
    
    @ViewBuilder
    func optionsView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(options, id: \.self) { option in
                HStack(spacing: 0) {
                    TextField(option, text: $artist)
                        .textFieldStyle(CustomTextFieldStyle(text: $artist, icon: "plus"))
                }
                .bold()
                .foregroundStyle(.white)
                .animation(.none, value: selection)
                .frame(height: 40)
                .contentShape(.rect)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .padding(.bottom, 4)
        .transition(.move(edge: anchor == .top ? .bottom : .top))
    }
    
    enum Anchor {
        case top
        case bottom
    }
}
