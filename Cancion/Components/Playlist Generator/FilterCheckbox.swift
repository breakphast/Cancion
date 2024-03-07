//
//  Checkbox.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/21/24.
//

import SwiftUI

struct FilterCheckbox: View {
    @Environment(PlaylistGeneratorViewModel.self) var viewModel
    
    let title: String
    let icon: String?
    let cornerRadius: CGFloat
    let strokeColor: Color
    let type: CheckboxType
    
    var body: some View {
        HStack {
            checkbox
            
            Text(title)
                .foregroundStyle(.oreo)
                .fontWeight(.semibold)
                .font(.title3)
            
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(.oreo)
                    .font(.subheadline.bold())
            }
        }
    }
    
    var selectedd: Bool {
        switch type {
        case .match:
            return viewModel.smartRulesActive
        case .limit:
            return viewModel.limitActive
        case .liveUpdating:
            return viewModel.liveUpdating
        }
    }
    
    private var checkbox: some View {
        Button {
            withAnimation {
                handleCheckboxToggle()
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fillColorForType())
                    .frame(width: 33, height: 33)
                    .shadow(radius: 2)
                Image(systemName: "checkmark")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
                    .opacity(fillColorForType() == Color.naranja.opacity(0.9) ? 1 : 0)
            }
        }
    }
    
    private func handleCheckboxToggle() {
        switch type {
        case .match:
            viewModel.smartRulesActive.toggle()
        case .limit:
            viewModel.limitActive.toggle()
        case .liveUpdating:
            viewModel.liveUpdating.toggle()
        }
    }
    
    private func fillColorForType() -> Color {
        switch type {
        case .match:
            return viewModel.smartRulesActive ? Color.naranja.opacity(0.9) : Color.white
        case .limit:
            return viewModel.limitActive ? Color.naranja.opacity(0.9) : Color.white
        case .liveUpdating:
            return viewModel.liveUpdating ? Color.naranja.opacity(0.9) : Color.white
        }
    }
}

enum CheckboxType: String {
    case match = "match"
    case limit = "limit"
    case liveUpdating = "liveUpdating"
}
