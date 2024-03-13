//
//  DatePicker.swift
//  Cancion
//
//  Created by Desmond Fitch on 3/13/24.
//

import SwiftUI

struct DatePickr: View {
    @State private var birthDate = Date.now
    let dateFormatter = DateFormatter()
    
    init() {
        dateFormatter.dateFormat = "MMM dd, yyyy"
    }
    
    var body: some View {
        VStack {
            ZStack {
                DatePicker("Date", selection: $birthDate, in: ...Date.now, displayedComponents: .date)
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.white)
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.oreo.opacity(0.1))
                    Text(dateFormatter.string(from: birthDate))
                        .foregroundStyle(.oreo)
                        .font(.caption.bold())
                }
                .allowsHitTesting(false)
            }
            .frame(height: 44)
        }
    }
}

#Preview {
    DatePickr()
}
