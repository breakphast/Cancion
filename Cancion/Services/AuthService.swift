//
//  AuthService.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/15/24.
//

import SwiftUI
import MusicKit

@Observable class AuthService {
    static let shared = AuthService()
    var status: MusicAuthorization.Status
    
    init() {
        let authStatus = MusicAuthorization.currentStatus
        status = authStatus
    }
}
