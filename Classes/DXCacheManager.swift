//
//  DXCacheManager.swift
//  Yasir N.Ramaya
//
//  Created by Yasir N.Ramaya on 7/28/20.
//  Copyright © 2020 Yasir N.Ramaya All rights reserved.
//

import Foundation
import AVFoundation

class DXCacheManager {
    
    static let shared = DXCacheManager()
    private init () {}
    
    let genericID = 100
    let qualityIndex = 0
    let subtitleIndex = 1
    let selectedAssetIndex = 2
    let assetStartTime = 3
    
    func buildKey(type:Int, id:Int) -> String{
        return "\(type),\(id)"
    }
    
    func saveIndex(value:Int,key:String){
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func saveTime(value:CMTime,key:String){
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func getSavedTime(key:String) -> CMTime{
        return UserDefaults.standard.cmtime(forKey: key) ?? CMTime(
            seconds: Double(0),
            preferredTimescale: CMTimeScale(NSEC_PER_SEC)
        )
    }
    
    func getSavedIndex(key:String) -> Int{
        return UserDefaults.standard.integer(forKey: key )
    }
    
}


