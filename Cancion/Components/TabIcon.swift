//
//  TabIcon.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/27/24.
//

import SwiftUI

struct TabIcon: View {
    let icon: String
    var playButton = false
    var progress: CGFloat
    var isPlaying: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(playButton ? Color.white.opacity(0.9) : .oreo)
                .shadow(radius: 10)
            if playButton {
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.naranja)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.linear, value: progress)
            }
            Image(systemName: icon)
                .bold()
                .foregroundStyle(playButton ? isPlaying ? .naranja : .oreo : Color.white)
                .font(playButton ? .title2 : .body)
        }
        .frame(width: playButton ? 66 : 55)
    }
}
