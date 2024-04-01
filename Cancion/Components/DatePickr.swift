//
//  DatePicker.swift
//  Cancion
//
//  Created by Desmond Fitch on 3/13/24.
//

import SwiftUI

struct DatePickr: View {
    let filter: Filter
    @State private var filteredDate = Date()
    @Environment(PlaylistGeneratorViewModel.self) var playlistGeneratorViewModel
    init(filter: Filter) {
        self.filter = filter
    }
    
    var filterDateText: String {
        if let filterDateString = playlistGeneratorViewModel.filteredDates[filter.id.uuidString] {
            return filterDateString
        }
        return Helpers().datePickerFormatter.string(from: Date())
    }
    
    var body: some View {
        VStack {
            ZStack {
                DatePicker("Date", selection: $filteredDate, in: ...Date.now, displayedComponents: .date)
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.white)
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.oreo.opacity(0.1))
                    Text(filterDateText)
                        .foregroundStyle(.oreo)
                        .font(.caption.bold())
                }
                .allowsHitTesting(false)
                .onChange(of: filteredDate) { oldValue, newValue in
                    let dateeee = Helpers().datePickerFormatter.string(from: newValue)
                    playlistGeneratorViewModel.filteredDates[filter.id.uuidString] = dateeee
                }
                .task {
                    if let filterDateString = filter.date {
                        playlistGeneratorViewModel.filteredDates[filter.id.uuidString] = filterDateString
                    } else {
                        playlistGeneratorViewModel.filteredDates[filter.id.uuidString] = Helpers().datePickerFormatter.string(from: Date())
                    }
                }
            }
            .frame(height: 44)
        }
    }
}
