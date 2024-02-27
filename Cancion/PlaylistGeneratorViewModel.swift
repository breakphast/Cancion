//
//  PlaylistGeneratorViewModel.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/21/24.
//

import Foundation
import SwiftUI

@Observable class PlaylistGeneratorViewModel {
    static let options = ["Artist", "Title", "Play Count"]
    static let conditionals = ["is", "contains", "does not contain"]
    var playlists = [PlaylistModel]()
    var model = PlaylistModel()
}
