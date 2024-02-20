//
//  CancionView.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/15/24.
//

import SwiftUI
import MusicKit

struct CancionView: View {
    var body: some View {
        VStack {
            Text("HEijdiej")
        }
    }
    func openURL(url: URL) {
        UIApplication.shared.open(url)
    }
    private func moreSongsElement(_ size: CGSize) -> some View {
        HStack(spacing: 16) {
            [Image(.uzi), Image(.uzi)].randomElement()!
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(.rect(cornerRadius: 8, style: .continuous))
                .frame(width: 44)
                .shadow(color: .white.opacity(0.2), radius: 5)
            VStack(alignment: .leading) {
                Text("Leh Go")
                    .bold()
                Text("Osamason")
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("3:12")
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
        .foregroundStyle(.white)
        .fontDesign(.rounded)
    }
}


#Preview {
    CancionView()
}
