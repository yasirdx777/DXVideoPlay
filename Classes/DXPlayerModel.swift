//
//  PlayerModel.swift
//  weeanaiOSPlayer
//
//  Created by Yasir N.Ramaya on 7/7/20.
//  Copyright © 2020 qi. All rights reserved.
//

import Foundation

struct DXPlayerModel {
    var id:Int
    var assetItems:[AssetItem]
}

struct AssetItem {
    var id:Int
    var itemTitle:String
    var itemSubtitle:URL?
    var itemVideoSources:[VideoSource]
}

struct VideoSource {
    var sourceTitel:String
    var sourceVideo:URL
}
