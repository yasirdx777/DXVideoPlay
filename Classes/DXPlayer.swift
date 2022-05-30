//
//  PlayerLayer.swift
//  Yasir N.Ramaya
//
//  Created by Yasir N.Ramaya on 7/7/20.
//  Copyright © 2020 Yasir N.Ramaya. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit

class DXPlayer:UIView, DXPlayerViewProtocol {
    
    
    override public class var layerClass: Swift.AnyClass {
        return AVPlayerLayer.self
    }
    
    class TapCookie {
        weak var content: AnyObject?
        
        init(content: AnyObject) {
            self.content = content
        }
        
        deinit {
            print("TapCookie deinit")    // should appear after finalize
        }
    }
    
    /**************/
    
    var playerControll: DXPlayerControllViewProtocol?
    public var playerLayer:AVPlayerLayer?
    var playerModel:DXPlayerModel?
    var selectedAssetIndex:Int?
    
    /**************/
    
    let activityIndictor: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            return UIActivityIndicatorView(style: .medium)
        } else {
            return UIActivityIndicatorView(style: .white)
        }
    }()
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        self.backgroundColor = .black
    }
    
    func initPlayer(playerModel:DXPlayerModel){
        
        self.addSubview(activityIndictor)
        
        activityIndictor.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(16)
        }
        
        self.playerModel = playerModel
        
        playerLayer = self.layer as? AVPlayerLayer
        playerLayer?.videoGravity = .resizeAspect
        playerLayer?.contentsGravity = .resizeAspect
        playerLayer?.frame = self.bounds
        
        
        
        let selectedAssetIndexKey = DXCacheManager.shared.buildKey(type: DXCacheManager.shared.selectedAssetIndex, id: playerModel.id)
        
        selectedAssetIndex = DXCacheManager.shared.getSavedIndex(key: selectedAssetIndexKey)
        
        setAssetItemsPlayerView(playerModel.assetItems, selectedIndex: selectedAssetIndex ?? 0)
        
        let assetItem = playerModel.assetItems[selectedAssetIndex ?? 0]
        
        setAssetItemPlayerView(assetItem)
        
        let assetTimeKey = DXCacheManager.shared.buildKey(type: DXCacheManager.shared.assetStartTime, id: assetItem.id)
        let assetStartTime = DXCacheManager.shared.getSavedTime(key: assetTimeKey)
        
        let qualityIndexKey = DXCacheManager.shared.buildKey(type: DXCacheManager.shared.qualityIndex, id: DXCacheManager.shared.genericID)
        let qualityIndex = DXCacheManager.shared.getSavedIndex(key: qualityIndexKey)
        
        
        playAssetItem(assetItem, selectedQaulity: qualityIndex, currentTime: assetStartTime)
        
    }
    
    func getCurrentAssetTime() -> CMTime {
        return playerLayer?.player?.currentItem?.currentTime() ?? CMTime(
            seconds: Double(0),
            preferredTimescale: CMTimeScale(NSEC_PER_SEC)
        )
    }
    
    func changeAssetItem(index: Int) {
        
        // Save time
        let assetItem = playerModel?.assetItems[selectedAssetIndex ?? 0]
        
        let assetTimeKey = DXCacheManager.shared.buildKey(type: DXCacheManager.shared.assetStartTime, id: assetItem?.id ?? 0)
        DXCacheManager.shared.saveTime(value: getCurrentAssetTime(), key: assetTimeKey)
        
        // Save new index
        let selectedAssetIndexKey = DXCacheManager.shared.buildKey(type: DXCacheManager.shared.selectedAssetIndex, id: playerModel?.id ?? 0)
        DXCacheManager.shared.saveIndex(value: index, key: selectedAssetIndexKey)
        
        // Set index
        selectedAssetIndex = index
        
        if let assetItem = playerModel?.assetItems[index] {
            
            // Set View
            playerControll?.clearSegmentedControl()
            setAssetItemPlayerView(assetItem)
            
            // Get asset start time
            let assetTimeKey = DXCacheManager.shared.buildKey(type: DXCacheManager.shared.assetStartTime, id: assetItem.id)
            let assetStartTime = DXCacheManager.shared.getSavedTime(key: assetTimeKey)
            
            // Get selected quality
            let qualityIndexKey = DXCacheManager.shared.buildKey(type: DXCacheManager.shared.qualityIndex, id: DXCacheManager.shared.genericID)
            let qualityIndex = DXCacheManager.shared.getSavedIndex(key: qualityIndexKey)
            
            // Change Asset
            changeAssetItem(assetItem, selectedQaulity: qualityIndex, currentTime: assetStartTime, changeSubtitle: true)
        }
        
    }
    
    func changeQuality(index: Int) {
        
        // Save quality index
        let qualityIndexKey = DXCacheManager.shared.buildKey(type: DXCacheManager.shared.qualityIndex, id: DXCacheManager.shared.genericID)
        DXCacheManager.shared.saveIndex(value: index, key: qualityIndexKey)
        
        if let assetItem = playerModel?.assetItems[selectedAssetIndex ?? 0], let currentTime = self.playerLayer?.player?.currentItem?.currentTime() {
            
            //* Change Asset for change quality
            changeAssetItem(assetItem, selectedQaulity: index, currentTime: currentTime, changeSubtitle: false)
        }
    }
    
    func changeSubtitleSetting(index: Int) {
        setSubtitleSetting(index: index)
    }
    
    
    // set assets into view list
    private func setAssetItemsPlayerView(_ assetItems: [AssetItem], selectedIndex:Int){
        if assetItems.count > 1 {
            
            var assetItemsArr = [String]()
            
            assetItems.forEach { (item) in
                assetItemsArr.append(item.itemTitle)
            }
            
            playerControll?.createQueue(assetItemsArr, selectedIndex: selectedIndex)
        }
    }
    
    // set asset settings to segment view
    private func setAssetItemPlayerView(_ assetItem: AssetItem){
        var qauiltiesArr = [String]()
        assetItem.itemVideoSources.forEach { (videoSource) in
            qauiltiesArr.append(videoSource.sourceTitel)
        }
        
        let qualityIndexKey = DXCacheManager.shared.buildKey(type: DXCacheManager.shared.qualityIndex, id: DXCacheManager.shared.genericID)
        
        let qualityIndex = DXCacheManager.shared.getSavedIndex(key: qualityIndexKey)
        
        if qauiltiesArr.count > 1 {
            playerControll?.createQaulitiesSegmentedControl(qauiltiesArr, selectedIndex: qualityIndex)
        }
        
        let subtitleIndexKey = DXCacheManager.shared.buildKey(type: DXCacheManager.shared.subtitleIndex, id: DXCacheManager.shared.genericID)
        
        let subtitleIndex = DXCacheManager.shared.getSavedIndex(key: subtitleIndexKey)
        
        if assetItem.itemSubtitle != nil {
            playerControll?.createSubtitleSegmentedControl(subtitleItems(), selectedIndex: subtitleIndex)
        }
    }
    
    func subtitleItems() -> [String]{
        let locale = Locale.current.languageCode
        return locale ?? "en" == "en" ? ["Normal","Big","Small","Hide"] : ["طبيعي","كبير","صغير","اخفاء"]
    }
    
    
    private func playAssetItem(_ assetItem: AssetItem, selectedQaulity:Int, currentTime:CMTime){
        
        activityIndictor.startAnimating()
        
        var qaulityIndex = selectedQaulity
        
        if assetItem.itemVideoSources.count - 1 < selectedQaulity {
            qaulityIndex = assetItem.itemVideoSources.count - 1
        }
        
        let videoSource = assetItem.itemVideoSources[qaulityIndex].sourceVideo
        let asset = AVAsset(url: videoSource)
        let playerItem = AVPlayerItem(asset: asset)
        
        playerLayer?.player = AVPlayer(playerItem: playerItem)
        
        playerLayer?.player?.seek(to: currentTime,
                                  toleranceBefore: CMTime.zero,
                                  toleranceAfter: CMTime.zero)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.playerLayer?.player?.play()
            
            if assetItem.itemSubtitle != nil {
                self?.addSubtitles().open(fileFromRemote: assetItem.itemSubtitle!, encoding: String.Encoding.utf8)
                
                let subtitleIndexKey = DXCacheManager.shared.buildKey(type: DXCacheManager.shared.subtitleIndex, id: DXCacheManager.shared.genericID)
                
                let subtitleIndex = DXCacheManager.shared.getSavedIndex(key: subtitleIndexKey)
                
                self?.initSubtitleSetting(index: subtitleIndex)
            }else{
                self?.addPeriodicNotification(parsedPayload: nil)
            }
            
            self?.mixAudio()
        }
        
        
    }
    
    
    private func changeAssetItem(_ assetItem: AssetItem, selectedQaulity:Int, currentTime:CMTime, changeSubtitle:Bool){
        
        activityIndictor.startAnimating()
        
        var qaulityIndex = selectedQaulity
        
        if assetItem.itemVideoSources.count - 1 < selectedQaulity {
            qaulityIndex = assetItem.itemVideoSources.count - 1
        }
        
        let videoSource = assetItem.itemVideoSources[qaulityIndex].sourceVideo
        let asset = AVAsset(url: videoSource)
        
        let playerItem = AVPlayerItem(asset: asset)
        
        playerLayer?.player?.replaceCurrentItem(with: playerItem)
        
        playerLayer?.player?.seek(to: currentTime,
                                  toleranceBefore: CMTime.zero,
                                  toleranceAfter: CMTime.zero)
        
        playerLayer?.player?.play()
        
        if changeSubtitle {
            if assetItem.itemSubtitle != nil {
                self.addSubtitles().open(fileFromRemote: assetItem.itemSubtitle!, encoding: String.Encoding.utf8)
                
                let subtitleIndexKey = DXCacheManager.shared.buildKey(type: DXCacheManager.shared.subtitleIndex, id: DXCacheManager.shared.genericID)
                
                let subtitleIndex = DXCacheManager.shared.getSavedIndex(key: subtitleIndexKey)
                
                self.initSubtitleSetting(index: subtitleIndex)
            }else{
                self.addPeriodicNotification(parsedPayload: nil)
            }
        }
        
        mixAudio()
    }
    
    func initSubtitleSetting(index: Int){
        // change subtitle settings
        switch index {
        case 0:
            self.subtitleLabel?.font = .systemFont(ofSize: 24)
            self.subtitleLabel?.isHidden = false
        case 1:
            self.subtitleLabel?.font = .boldSystemFont(ofSize: 34)
            self.subtitleLabel?.isHidden = false
        case 2:
            self.subtitleLabel?.font = .boldSystemFont(ofSize: 16)
            self.subtitleLabel?.isHidden = false
        case 3:
            self.subtitleLabel?.isHidden = true
        default:
            self.subtitleLabel?.font = .systemFont(ofSize: 16)
            self.subtitleLabel?.isHidden = false
        }
    }
    
    func setSubtitleSetting(index: Int){
        // change subtitle settings
        switch index {
        case 0:
            self.subtitleLabel?.font = .systemFont(ofSize: 24)
            self.subtitleLabel?.isHidden = false
            
            // Save quality index
            let qualityIndexKey = DXCacheManager.shared.buildKey(type: DXCacheManager.shared.subtitleIndex, id: DXCacheManager.shared.genericID)
            DXCacheManager.shared.saveIndex(value: index, key: qualityIndexKey)
            
        case 1:
            self.subtitleLabel?.font = .boldSystemFont(ofSize: 34)
            self.subtitleLabel?.isHidden = false
            
            // Save quality index
            let qualityIndexKey = DXCacheManager.shared.buildKey(type: DXCacheManager.shared.subtitleIndex, id: DXCacheManager.shared.genericID)
            DXCacheManager.shared.saveIndex(value: index, key: qualityIndexKey)
            
        case 2:
            self.subtitleLabel?.font = .boldSystemFont(ofSize: 16)
            self.subtitleLabel?.isHidden = false
            
            // Save quality index
            let qualityIndexKey = DXCacheManager.shared.buildKey(type: DXCacheManager.shared.subtitleIndex, id: DXCacheManager.shared.genericID)
            DXCacheManager.shared.saveIndex(value: index, key: qualityIndexKey)
            
        case 3:
            self.subtitleLabel?.isHidden = true
        default:
            self.subtitleLabel?.font = .systemFont(ofSize: 16)
            self.subtitleLabel?.isHidden = false
        }
    }
    
    
    func play() {
        if playerLayer?.player?.timeControlStatus == .playing {
            playerLayer?.player?.pause()
            playerControll?.changePlayStatus(isPlaying:false)
        }else{
            playerLayer?.player?.play()
            playerControll?.changePlayStatus(isPlaying:true)
        }
    }
    
    func rewind() {
        if let currentTime = playerLayer?.player?.currentTime() {
            var newTime = CMTimeGetSeconds(currentTime) - 10
            if newTime <= 0 {
                newTime = 0
            }
            playerLayer?.player?.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
        }
    }
    
    func forward() {
        if let currentTime = playerLayer?.player?.currentTime(), let duration = playerLayer?.player?.currentItem?.duration {
            var newTime = CMTimeGetSeconds(currentTime) + 10
            if newTime >= CMTimeGetSeconds(duration) {
                newTime = CMTimeGetSeconds(duration)
            }
            playerLayer?.player?.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
        }
    }
    
    func seek(value: CMTime) {
        playerLayer?.player?.seek(to: value,
                                  toleranceBefore: CMTime.zero,
                                  toleranceAfter: CMTime.zero)
    }
    
    
    func videoGravity() -> AVLayerVideoGravity {
        return playerLayer?.videoGravity ?? AVLayerVideoGravity.resizeAspect
    }
    
    func changeVideoGravity(videoGravity: AVLayerVideoGravity) {
        playerLayer?.videoGravity = videoGravity
    }
    
    func closePlayer() {
        
        // Save time
        let assetItem = playerModel?.assetItems[selectedAssetIndex ?? 0]
        
        let assetTimeKey = DXCacheManager.shared.buildKey(type: DXCacheManager.shared.assetStartTime, id: assetItem?.id ?? 0)
        DXCacheManager.shared.saveTime(value: getCurrentAssetTime(), key: assetTimeKey)
        
        playerLayer?.player = nil
        playerLayer = nil
        playerModel = nil
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
