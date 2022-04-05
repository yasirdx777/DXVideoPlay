//
//  DXPlayerViewProtocol.swift
//  weeanaiOSPlayer
//
//  Created by Yasir N.Ramaya on 7/7/20.
//  Copyright © 2020 qi. All rights reserved.
//

import Foundation
import AVFoundation

protocol DXPlayerViewProtocol: AnyObject {
    func play()
    func rewind()
    func forward()
    func seek(value:CMTime)
    func changeQuality(index:Int)
    func changeSubtitleSetting(index:Int)
    func changeAssetItem(index:Int)
    func videoGravity() -> AVLayerVideoGravity
    func changeVideoGravity(videoGravity:AVLayerVideoGravity)
    func closePlayer()
}
