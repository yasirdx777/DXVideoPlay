//
//  DXPlayerControllViewProtocol.swift
//  weeanaiOSPlayer
//
//  Created by Yasir N.Ramaya on 7/7/20.
//  Copyright © 2020 qi. All rights reserved.
//

import Foundation
import AVFoundation

protocol DXPlayerControllViewProtocol: AnyObject {
    func changePlayStatus(isPlaying:Bool)
    func setSliderMax(maxProgress: Float)
    func changeSliderProgress(progress: Float)
    func setCurrentTime(currentTime: String)
    func setDuration(duration: String)
    func createQaulitiesSegmentedControl(_ items:[String], selectedIndex:Int)
    func createSubtitleSegmentedControl(_ items:[String], selectedIndex:Int)
    func clearSegmentedControl()
    func createQueue(_ items:[String], selectedIndex:Int)
}
