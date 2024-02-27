//
//  TabIcon.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/27/24.
//

import SwiftUI

struct TabIcon: View {
    let icon: String
    let active: Bool
    @Binding var progress: CGFloat
    var isPlaying: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(active ? Color.white.opacity(0.9) : .oreo)
                .shadow(radius: 10)
            if active {
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.naranja)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.linear, value: progress)
            }
            Image(systemName: icon)
                .bold()
                .foregroundStyle(active ? isPlaying ? .naranja : .oreo : Color.white)
                .font(active ? .title2 : .body)
        }
        .frame(width: active ? 66 : 55)
    }
}
