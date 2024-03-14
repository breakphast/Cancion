//
//  DatePicker.swift
//  Cancion
//
//  Created by Desmond Fitch on 3/13/24.
//

import SwiftUI

struct DatePickr: View {
    @Bindable var playlistGenViewModel: PlaylistGeneratorViewModel
    
    let dateFormatter = DateFormatter()
    init(playlistGenViewModel: PlaylistGeneratorViewModel) {
        self.playlistGenViewModel = playlistGenViewModel
        dateFormatter.dateFormat = "MMM dd, yyyy"
    }
    
    var body: some View {
        VStack {
            ZStack {
                DatePicker("Date", selection: $playlistGenViewModel.dateAdded, in: ...Date.now, displayedComponents: .date)
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.white)
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.oreo.opacity(0.1))
                    Text(dateFormatter.string(from: playlistGenViewModel.dateAdded))
                        .foregroundStyle(.oreo)
                        .font(.caption.bold())
                }
                .allowsHitTesting(false)
            }
            .frame(height: 44)
        }
    }
}
