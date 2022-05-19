//
//  PlayerModel.swift
//  weeanaiOSPlayer
//
//  Created by Yasir N.Ramaya on 7/7/20.
//  Copyright © 2020 qi. All rights reserved.
//

import Foundation

public struct DXPlayerModel {
    
    public init(id:Int, assetItems:[AssetItem]) {
        self.id = id
        self.assetItems = assetItems
    }
    
    var id:Int
    var assetItems:[AssetItem]
}

public struct AssetItem {
    
    public init(id:Int, itemTitle:String, itemSubtitle:URL?, itemVideoSources:[VideoSource]) {
        self.id = id
        self.itemTitle = itemTitle
        self.itemSubtitle = itemSubtitle
        self.itemVideoSources = itemVideoSources
    }
    
    var id:Int
    var itemTitle:String
    var itemSubtitle:URL?
    var itemVideoSources:[VideoSource]
}

public struct VideoSource {
    
    public init(sourceTitel:String, sourceVideo:URL) {
        self.sourceTitel = sourceTitel
        self.sourceVideo = sourceVideo
    }
    
    var sourceTitel:String
    var sourceVideo:URL
}
