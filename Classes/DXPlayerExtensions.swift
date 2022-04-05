//
//  Subtitles.swift
//  weeanaiOSPlayer
//
//  Created by Yasir N.Ramaya on 7/26/20.
//  Copyright © 2020 qi. All rights reserved.
//

import ObjectiveC
import MediaPlayer
import AVKit
import CoreMedia

let locale = Locale.current.languageCode

private struct AssociatedKeys {
    static var FontKey = "FontKey"
    static var ColorKey = "FontKey"
    static var SubtitleKey = "SubtitleKey"
    static var SubtitleHeightKey = "SubtitleHeightKey"
    static var PayloadKey = "PayloadKey"
}

@objc public class Subtitles : NSObject {
    
    // MARK: - Properties
    fileprivate var parsedPayload: NSDictionary?
    
    // MARK: - Public methods
    public init(file filePath: URL, encoding: String.Encoding = String.Encoding.utf8) {
        
        // Get string
        let string = try! String(contentsOf: filePath, encoding: encoding)
        
        // Parse string
        parsedPayload = Subtitles.parseSubRip(string)
        
    }
    
    @objc public init(subtitles string: String) {
        
        // Parse string
        parsedPayload = Subtitles.parseSubRip(string)
        
    }
    
    /// Search subtitles at time
    ///
    /// - Parameter time: Time
    /// - Returns: String if exists
    @objc public func searchSubtitles(at time: TimeInterval) -> String? {
        
        return Subtitles.searchSubtitles(parsedPayload, time)
        
    }
    
    // MARK: - Private methods
    
    /// Subtitle parser
    ///
    /// - Parameter payload: Input string
    /// - Returns: NSDictionary
    fileprivate static func parseSubRip(_ payload: String) -> NSDictionary? {
        
        do {
            
            // Prepare payload
            var payload = payload.replacingOccurrences(of: "\n\r\n", with: "\n\n")
            payload = payload.replacingOccurrences(of: "\n\n\n", with: "\n\n")
            payload = payload.replacingOccurrences(of: "\r\n", with: "\n")
            
            // Parsed dict
            let parsed = NSMutableDictionary()
            
            // Get groups
            let regexStr = "(\\d+)\\n([\\d:,.]+)\\s+-{2}\\>\\s+([\\d:,.]+)\\n([\\s\\S]*?(?=\\n{2,}|$))"
            let regex = try NSRegularExpression(pattern: regexStr, options: .caseInsensitive)
            let matches = regex.matches(in: payload, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, payload.count))
            for m in matches {
                
                let group = (payload as NSString).substring(with: m.range)
                
                // Get index
                var regex = try NSRegularExpression(pattern: "^[0-9]+", options: .caseInsensitive)
                var match = regex.matches(in: group, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, group.count))
                guard let i = match.first else {
                    continue
                }
                let index = (group as NSString).substring(with: i.range)
                
                // Get "from" & "to" time
                regex = try NSRegularExpression(pattern: "\\d{1,2}:\\d{1,2}:\\d{1,2}[,.]\\d{1,3}", options: .caseInsensitive)
                match = regex.matches(in: group, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, group.count))
                guard match.count == 2 else {
                    continue
                }
                guard let from = match.first, let to = match.last else {
                    continue
                }
                
                var h: TimeInterval = 0.0, m: TimeInterval = 0.0, s: TimeInterval = 0.0, c: TimeInterval = 0.0
                
                let fromStr = (group as NSString).substring(with: from.range)
                var scanner = Scanner(string: fromStr)
                scanner.scanDouble(&h)
                scanner.scanString(":", into: nil)
                scanner.scanDouble(&m)
                scanner.scanString(":", into: nil)
                scanner.scanDouble(&s)
                scanner.scanString(",", into: nil)
                scanner.scanDouble(&c)
                let fromTime = (h * 3600.0) + (m * 60.0) + s + (c / 1000.0)
                
                let toStr = (group as NSString).substring(with: to.range)
                scanner = Scanner(string: toStr)
                scanner.scanDouble(&h)
                scanner.scanString(":", into: nil)
                scanner.scanDouble(&m)
                scanner.scanString(":", into: nil)
                scanner.scanDouble(&s)
                scanner.scanString(",", into: nil)
                scanner.scanDouble(&c)
                let toTime = (h * 3600.0) + (m * 60.0) + s + (c / 1000.0)
                
                // Get text & check if empty
                let range = NSMakeRange(0, to.range.location + to.range.length + 1)
                guard (group as NSString).length - range.length > 0 else {
                    continue
                }
                let text = (group as NSString).replacingCharacters(in: range, with: "")
                
                // Create final object
                let final = NSMutableDictionary()
                final["from"] = fromTime
                final["to"] = toTime
                final["text"] = text
                parsed[index] = final
                
            }
            
            return parsed
            
        } catch {
            
            return nil
            
        }
        
    }
    
    /// Search subtitle on time
    ///
    /// - Parameters:
    ///   - payload: Inout payload
    ///   - time: Time
    /// - Returns: String
    fileprivate static func searchSubtitles(_ payload: NSDictionary?, _ time: TimeInterval) -> String? {
        
        let predicate = NSPredicate(format: "(%f >= %K) AND (%f <= %K)", time, "from", time, "to")
        
        guard let values = payload?.allValues, let result = (values as NSArray).filtered(using: predicate).first as? NSDictionary else {
            return nil
        }
        
        guard let text = result.value(forKey: "text") as? String else {
            return nil
        }
        
        return text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
    }
    
}

extension DXPlayer {
    
    // MARK: - Public properties
    var subtitleLabel: UILabel? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.SubtitleKey) as? UILabel }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.SubtitleKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: - Private properties
    fileprivate var subtitleLabelHeightConstraint: NSLayoutConstraint? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.SubtitleHeightKey) as? NSLayoutConstraint }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.SubtitleHeightKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    fileprivate var parsedPayload: NSDictionary? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.PayloadKey) as? NSDictionary }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.PayloadKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: - Public methods
    func addSubtitles() -> Self {
        
        // Create label
        addSubtitleLabel()
        
        return self
        
    }
    
    func open(fileFromLocal filePath: URL, encoding: String.Encoding = String.Encoding.utf8) {
        
        let contents = try! String(contentsOf: filePath, encoding: encoding)
        show(subtitles: contents)
    }
    
    func open(fileFromRemote filePath: URL, encoding: String.Encoding = String.Encoding.utf8) {
        
        
        subtitleLabel?.text = "..."
        URLSession.shared.dataTask(with: filePath, completionHandler: { (data, response, error) -> Void in
            
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                
                //Check status code
                if statusCode != 200 {
                    NSLog("Subtitle Error: \(httpResponse.statusCode) - \(error?.localizedDescription ?? "")")
                    return
                }
            }
            // Update UI elements on main thread
            DispatchQueue.main.async(execute: {
                self.subtitleLabel?.text = ""
                
                if let checkData = data as Data? {
                    if let contents = String(data: checkData, encoding: encoding) {
                        self.show(subtitles: contents)
                    }
                }
                
            })
        }).resume()
    }
    
    
    
    func show(subtitles string: String) {
        
        // Parse
        parsedPayload = Subtitles.parseSubRip(string)
        addPeriodicNotification(parsedPayload: parsedPayload!)
        
    }
    
    func showByDictionary(dictionaryContent: NSMutableDictionary) {
        
        // Add Dictionary content direct to Payload
        parsedPayload = dictionaryContent
        addPeriodicNotification(parsedPayload: parsedPayload!)
        
    }
    
    func addPeriodicNotification(parsedPayload: NSDictionary?) {
        // Add periodic notifications
        self.playerLayer?.player?.addPeriodicTimeObserver(
            forInterval: CMTimeMake(value: 1, timescale: 60),
            queue: DispatchQueue.main,
            using: { [weak self] (time) -> Void in
                
                if parsedPayload != nil {
                    
                    guard let strongSelf = self else { return }
                    guard let label = strongSelf.subtitleLabel else { return }
                    
                    // Search && show subtitles
                    label.text = Subtitles.searchSubtitles(strongSelf.parsedPayload, time.seconds)
                    
                    // Adjust size
                    let baseSize = CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude)
                    let rect = label.sizeThatFits(baseSize)
                    if label.text != nil {
                        strongSelf.subtitleLabelHeightConstraint?.constant = rect.height + 5.0
                    } else {
                        strongSelf.subtitleLabelHeightConstraint?.constant = rect.height
                    }
                }
                
                // our needs
                
                if let duration =  self?.playerLayer?.player?.currentItem?.duration {
                    
                    let durationFloat64 : Float64 = CMTimeGetSeconds(duration)
                    let durationFloat:Float = Float(durationFloat64)
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else {return}
                        if durationFloat > 0 {
                            self.playerControll?.setSliderMax(maxProgress: durationFloat)
                            self.playerControll?.setDuration(duration: self.durationSecondsFormated(durationFloat))
                        }
                    }
                    
                }
                
                if let currentTime = self?.playerLayer?.player?.currentItem?.currentTime() {
                    
                    let currentTimeFloat64 : Float64 = CMTimeGetSeconds(currentTime)
                    let currentTimeFloat : Float = Float(currentTimeFloat64)
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else {return}
                        self.playerControll?.changeSliderProgress(progress: currentTimeFloat)
                        self.playerControll?.setCurrentTime(currentTime: self.currentTimeFormated(currentTimeFloat))
                    }
                }
                
                if self?.playerLayer?.player?.currentItem?.status == AVPlayerItem.Status.readyToPlay {
                    
                    if let isPlaybackLikelyToKeepUp = self?.playerLayer?.player?.currentItem?.isPlaybackLikelyToKeepUp {
                        if isPlaybackLikelyToKeepUp {
                            self?.activityIndictor.stopAnimating()
                        }else{
                            self?.activityIndictor.stopAnimating()
                        }
                    }
                }
                
        })
        
    }
    
    private func durationSecondsFormated(_ durationSeconds:Float) -> String {
        if !(durationSeconds.isNaN || durationSeconds.isInfinite) {
            return formatTimeFromSeconds(totalSeconds: Int32(durationSeconds))
        }else{
            return String(format: "%02d:%02d:%02d", 00,00,00)
        }
        
    }
    
    private func currentTimeFormated(_ currentTimeSeconds:Float) -> String{
        if !(currentTimeSeconds.isNaN || currentTimeSeconds.isInfinite) {
            return formatTimeFromSeconds(totalSeconds: Int32(currentTimeSeconds))
        }else{
            return String(format: "%02d:%02d:%02d", 00,00,00)
        }
    }
    
    
    private func formatTimeFromSeconds(totalSeconds: Int32) -> String {
        let seconds: Int32 = totalSeconds%60
        let minutes: Int32 = (totalSeconds/60)%60
        let hours: Int32 = totalSeconds/3600
        return String(format: "%02d:%02d:%02d", hours,minutes,seconds)
    }
    
    
    fileprivate func addSubtitleLabel() {
        
        guard let _ = subtitleLabel else {
            
            // Label
            subtitleLabel = UILabel()
            subtitleLabel?.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel?.backgroundColor = UIColor.clear
            subtitleLabel?.textAlignment = .center
            subtitleLabel?.numberOfLines = 0
            subtitleLabel?.font = UIFont.boldSystemFont(ofSize: UI_USER_INTERFACE_IDIOM() == .pad ? 40.0 : 22.0)
            subtitleLabel?.textColor = UIColor.white
            subtitleLabel?.numberOfLines = 0;
            subtitleLabel?.layer.shadowColor = UIColor.black.cgColor
            subtitleLabel?.layer.shadowOffset = CGSize(width: 1.0, height: 1.0);
            subtitleLabel?.layer.shadowOpacity = 0.9;
            subtitleLabel?.layer.shadowRadius = 1.0;
            subtitleLabel?.layer.shouldRasterize = true;
            subtitleLabel?.layer.rasterizationScale = UIScreen.main.scale
            subtitleLabel?.lineBreakMode = .byWordWrapping
            self.addSubview(subtitleLabel!)
            
            // Position
            var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[l]-(20)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["l" : subtitleLabel!])
            self.addConstraints(constraints)
            constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[l]-(30)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["l" : subtitleLabel!])
            self.addConstraints(constraints)
            subtitleLabelHeightConstraint = NSLayoutConstraint(item: subtitleLabel!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: 30.0)
            self.addConstraint(subtitleLabelHeightConstraint!)
            
            return
            
        }
        
    }
    
}


//Loading observer
extension DXPlayer {
    
    func mixAudio() {
        let tapInit: MTAudioProcessingTapInitCallback = {
            (tap, clientInfo, tapStorageOut) in
            
            // Make tap storage the same as clientInfo. I guess you might want them to be different.
            tapStorageOut.pointee = clientInfo
        }
        
        let tapProcess: MTAudioProcessingTapProcessCallback = {
            (tap, numberFrames, flags, bufferListInOut, numberFramesOut, flagsOut) in
            
            let status = MTAudioProcessingTapGetSourceAudio(tap, numberFrames, bufferListInOut, flagsOut, nil, numberFramesOut)
            if noErr != status {
                print("get audio: \(status)\n")
            }
            
            let cookie = Unmanaged<TapCookie>.fromOpaque(MTAudioProcessingTapGetStorage(tap)).takeUnretainedValue()
            guard let cookieContent = cookie.content else {
                print("Tap callback: cookie content was deallocated!")
                return
            }
            
            let appDelegateSelf = cookieContent as! DXPlayer
            print("cookie content \(appDelegateSelf)")
        }
        
        
        let tapFinalize: MTAudioProcessingTapFinalizeCallback = {
            (tap) in
            print("finalize \(tap)\n")
            
            // release cookie
            Unmanaged<TapCookie>.fromOpaque(MTAudioProcessingTapGetStorage(tap)).release()
        }
        
        let cookie = TapCookie(content: self)
        
        
        var callbacks = MTAudioProcessingTapCallbacks(
            version: kMTAudioProcessingTapCallbacksVersion_0,
            clientInfo: UnsafeMutableRawPointer(Unmanaged.passRetained(cookie).toOpaque()),
            init: tapInit,
            finalize: tapFinalize,
            prepare: nil,
            unprepare: nil,
            process: tapProcess)
        
        var tap: Unmanaged<MTAudioProcessingTap>?
        let err = MTAudioProcessingTapCreate(kCFAllocatorDefault, &callbacks, kMTAudioProcessingTapCreationFlag_PostEffects, &tap)
        assert(noErr == err);
        
        
        if let audioTrack = playerLayer?.player?.currentItem?.asset.tracks(withMediaType: .audio).first {
            let inputParams = AVMutableAudioMixInputParameters(track: audioTrack)
            
            inputParams.audioTapProcessor = tap?.takeRetainedValue()
            
            let audioMix = AVMutableAudioMix()
            audioMix.inputParameters = [inputParams]
            
            playerLayer?.player?.currentItem?.audioMix = audioMix
        }
    }
}



public extension AVPlayerViewController {
    
    // MARK: - Public properties
    var subtitleLabel: UILabel? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.SubtitleKey) as? UILabel }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.SubtitleKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: - Private properties
    fileprivate var subtitleLabelHeightConstraint: NSLayoutConstraint? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.SubtitleHeightKey) as? NSLayoutConstraint }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.SubtitleHeightKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    fileprivate var parsedPayload: NSDictionary? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.PayloadKey) as? NSDictionary }
        set (value) { objc_setAssociatedObject(self, &AssociatedKeys.PayloadKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: - Public methods
    func addSubtitles() -> Self {
        
        // Create label
        addSubtitleLabel()
        
        return self
        
    }
    
    func open(fileFromLocal filePath: URL, encoding: String.Encoding = String.Encoding.utf8) {
        
        let contents = try! String(contentsOf: filePath, encoding: encoding)
        show(subtitles: contents)
    }
    
    func open(fileFromRemote filePath: URL, encoding: String.Encoding = String.Encoding.utf8) {
        
        
        subtitleLabel?.text = "..."
        URLSession.shared.dataTask(with: filePath, completionHandler: { (data, response, error) -> Void in
            
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                
                //Check status code
                if statusCode != 200 {
                    NSLog("Subtitle Error: \(httpResponse.statusCode) - \(error?.localizedDescription ?? "")")
                    return
                }
            }
            // Update UI elements on main thread
            DispatchQueue.main.async(execute: {
                self.subtitleLabel?.text = ""
                
                if let checkData = data as Data? {
                    if let contents = String(data: checkData, encoding: encoding) {
                        self.show(subtitles: contents)
                    }
                }
                
            })
        }).resume()
    }
    
    
    
    func show(subtitles string: String) {
        
        // Parse
        parsedPayload = Subtitles.parseSubRip(string)
        addPeriodicNotification(parsedPayload: parsedPayload!)
        
    }
    
    func showByDictionary(dictionaryContent: NSMutableDictionary) {
        
        // Add Dictionary content direct to Payload
        parsedPayload = dictionaryContent
        addPeriodicNotification(parsedPayload: parsedPayload!)
        
    }
    
    func addPeriodicNotification(parsedPayload: NSDictionary) {
        // Add periodic notifications
        self.player?.addPeriodicTimeObserver(
            forInterval: CMTimeMake(value: 1, timescale: 60),
            queue: DispatchQueue.main,
            using: { [weak self] (time) -> Void in
                
                guard let strongSelf = self else { return }
                guard let label = strongSelf.subtitleLabel else { return }
                
                // Search && show subtitles
                label.text = Subtitles.searchSubtitles(strongSelf.parsedPayload, time.seconds)
                
                // Adjust size
                let baseSize = CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude)
                let rect = label.sizeThatFits(baseSize)
                if label.text != nil {
                    strongSelf.subtitleLabelHeightConstraint?.constant = rect.height + 5.0
                } else {
                    strongSelf.subtitleLabelHeightConstraint?.constant = rect.height
                }
                
        })
        
    }
    
    
    fileprivate func addSubtitleLabel() {
        
        guard let _ = subtitleLabel else {
            
            // Label
            subtitleLabel = UILabel()
            subtitleLabel?.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel?.backgroundColor = UIColor.clear
            subtitleLabel?.textAlignment = .center
            subtitleLabel?.numberOfLines = 0
            subtitleLabel?.font = UIFont.boldSystemFont(ofSize: UI_USER_INTERFACE_IDIOM() == .pad ? 40.0 : 22.0)
            subtitleLabel?.textColor = UIColor.white
            subtitleLabel?.numberOfLines = 0;
            subtitleLabel?.layer.shadowColor = UIColor.black.cgColor
            subtitleLabel?.layer.shadowOffset = CGSize(width: 1.0, height: 1.0);
            subtitleLabel?.layer.shadowOpacity = 0.9;
            subtitleLabel?.layer.shadowRadius = 1.0;
            subtitleLabel?.layer.shouldRasterize = true;
            subtitleLabel?.layer.rasterizationScale = UIScreen.main.scale
            subtitleLabel?.lineBreakMode = .byWordWrapping
            contentOverlayView?.addSubview(subtitleLabel!)
            
            // Position
            var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[l]-(20)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["l" : subtitleLabel!])
            contentOverlayView?.addConstraints(constraints)
            constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[l]-(30)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["l" : subtitleLabel!])
            contentOverlayView?.addConstraints(constraints)
            subtitleLabelHeightConstraint = NSLayoutConstraint(item: subtitleLabel!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: 30.0)
            contentOverlayView?.addConstraint(subtitleLabelHeightConstraint!)
            
            return
            
        }
        
    }
    
}

extension UserDefaults {
    func cmtime(forKey key: String) -> CMTime? {
        if let timescale = object(forKey: key + ".timescale") as? NSNumber {
            let seconds = double(forKey: key + ".seconds")
            return CMTime(seconds: seconds, preferredTimescale: timescale.int32Value)
        } else {
            return nil
        }
    }
    
    func set(_ cmtime: CMTime, forKey key: String) {
        let seconds = cmtime.seconds
        let timescale = cmtime.timescale
        
        set(seconds, forKey: key + ".seconds")
        set(NSNumber(value: timescale), forKey: key + ".timescale")
    }
}
