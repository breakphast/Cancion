//
//  PlaylistModel.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/21/24.
//

import Foundation
import SwiftUI

struct PlaylistModel {
    var id = UUID()
    var title = ""
    var smartRules = true
    var filters = [FilterModel]()
    var limit: Int = 25
    var liveUpdating = true
    var sortOption = ""
    var songs = [String]()
}
