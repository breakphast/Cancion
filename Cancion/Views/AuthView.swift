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
    @State private var authService = AuthService.shared
    
    var body: some View {
        VStack {
            if musicAuthorizationStatus == .notDetermined || musicAuthorizationStatus == .denied {
                Button {
                    authorizeAction()
                } label: {
                    Text("Authorize")
                        .bold()
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange.opacity(0.8))
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
                print(status.rawValue)
                await update(status: status)
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
