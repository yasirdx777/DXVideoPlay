//
//  ViewController.swift
//  DXVideoPlay
//
//  Created by yasirdx777 on 04/05/2022.
//  Copyright (c) 2022 yasirdx777. All rights reserved.
//

import UIKit
import DXVideoPlay

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
     
        
        let videoMP4Source480p = VideoSource(sourceTitel: "480p", sourceVideo: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
        let videoMP4Source720p = VideoSource(sourceTitel: "720p", sourceVideo: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
        let subtitleSRTSource = URL(string: "https://raw.githubusercontent.com/nick-vanpraet/subtitles-test/master/D20/FHSY/e01.srt")!
        
        
        let assetItemOne = AssetItem(id: 0, itemTitle: "Clip 1", itemSubtitle: subtitleSRTSource, itemVideoSources: [videoMP4Source480p, videoMP4Source720p])
        let assetItemTwo = AssetItem(id: 0, itemTitle: "Clip 1", itemSubtitle: subtitleSRTSource, itemVideoSources: [videoMP4Source480p, videoMP4Source720p])
        
        
        let model = DXPlayerModel(id: 101, assetItems: [assetItemOne, assetItemTwo])
        let dxPlayer = DXVideoPlay(playerModel: model)
        dxPlayer.modalPresentationStyle = .fullScreen
        
        present(dxPlayer, animated: true, completion: nil)
    }


}
