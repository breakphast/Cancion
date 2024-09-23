//
//  AuthView.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/15/24.
//

import SwiftUI
import MusicKit

struct AuthView: View {
    @Binding var musicAuthorizationStatus: MusicAuthorization.Status
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack {
            if musicAuthorizationStatus != .authorized {
                Button {
                    authorizeAction()
                } label: {
                    HStack(spacing: 12) {
                        Text("Authorize")
                            .kerning(1.2)
                        Image(.appleMusic)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.white)
                            .shadow(radius: 6)
                    )
                    .font(.title.bold())
                    .foregroundStyle(.appleMusic)
                }
            }
        }
    }
    
    @MainActor
    private func update(status: MusicAuthorization.Status) {
        withAnimation {
            self.musicAuthorizationStatus = status
        }
    }
    
    private func authorizeAction() {
        switch musicAuthorizationStatus {
        case .notDetermined:
            Task {
                let status = await MusicAuthorization.request()
                update(status: status)
            }
        case .denied:
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                openURL(settingsURL)
            }
        default:
            print("Error.")
        }
    }
}

#Preview {
    AuthView(musicAuthorizationStatus: .constant(.authorized))
}
