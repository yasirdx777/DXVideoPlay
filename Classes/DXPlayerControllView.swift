//
//  PlayerControll.swift
//  weeanaiOSPlayer
//
//  Created by Yasir N.Ramaya on 7/7/20.
//  Copyright © 2020 qi. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import AVFoundation

class DXPlayerControllView: UIView, DXPlayerControllViewProtocol {
   
    weak var player: DXPlayerViewProtocol?
    var playerViewController:DXPlayerViewControllerProtocol?
    
    lazy var playButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"ic_pause") ?? UIImage(), for: .normal)
        button.addTarget(self, action: #selector(DXPlayerControllView.playeVideo(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var rewindButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"ic_rewind") ?? UIImage(), for: .normal)
        button.addTarget(self, action: #selector(DXPlayerControllView.rewindVideo(_:)), for: .touchUpInside)
        if locale ?? "en" != "en"{
            button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
        return button
    }()
    
    lazy var forwardButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"ic_forward") ?? UIImage(), for: .normal)
        button.addTarget(self, action: #selector(DXPlayerControllView.forwardVideo(_:)), for: .touchUpInside)
        if locale ?? "en" != "en"{
            button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
        return button
    }()
    
    /* ----------- */
    
    lazy var seekSlider : UISlider = {
        let seekSlider = UISlider()
        seekSlider.setThumbImage(UIImage(named: "ic_thumbNormal") ?? UIImage(), for: .normal)
        seekSlider.setThumbImage(UIImage(named: "ic_thumbHighlighted") ?? UIImage(), for: .highlighted)
        seekSlider.tintColor = .white
        seekSlider.addTarget(self, action: #selector(DXPlayerControllView.seekBarValueChanged(_:)), for: .valueChanged)
        
        seekSlider.addTarget(self, action: #selector(DXPlayerControllView.seekBarTouchDown(_:)), for: .touchDown)
        
        seekSlider.addTarget(self, action: #selector(DXPlayerControllView.seekBarTouchCancel(_:)), for: .touchUpInside)
        return seekSlider
    }()
    
    
    lazy var durationLabel : UILabel = {
        let durationLabel = UILabel()
        durationLabel.textColor = .white
        durationLabel.textAlignment = .center
        durationLabel.text = "00:00:00"
        return durationLabel
    }()
    
    lazy var currentTimeLabel : UILabel = {
        let currentTimeLabel = UILabel()
        currentTimeLabel.textColor = .white
        currentTimeLabel.textAlignment = .center
        currentTimeLabel.text = "00:00:00"
        return currentTimeLabel
    }()
    
    
    /* ----------- */
    
    lazy var closeButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"ic_close") ?? UIImage(), for: .normal)
        button.addTarget(self, action: #selector(DXPlayerControllView.closePlayer(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var qaulityButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"ic_videoQuality") ?? UIImage(), for: .normal)
        button.addTarget(self, action: #selector(DXPlayerControllView.showQaulities(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var subtitleButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"ic_subtitle") ?? UIImage(), for: .normal)
        button.addTarget(self, action: #selector(DXPlayerControllView.showSubtitle(_:)), for: .touchUpInside)
        return button
    }()
    
    
    lazy var queueButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"ic_queue") ?? UIImage(), for: .normal)
        button.addTarget(self, action: #selector(DXPlayerControllView.showQueue(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var expandButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"ic_expand") ?? UIImage(), for: .normal)
        button.addTarget(self, action: #selector(DXPlayerControllView.showExpand(_:)), for: .touchUpInside)
        return button
    }()
    
    /* ----------- */
    
    var qaulitySegmentedControl : UISegmentedControl?
    var subtitleSegmentedControl : UISegmentedControl?
    
    var queueScrollView : UIScrollView?
    var queueStackView : UIStackView?
    
    
    /* ----------- */
    
    lazy var videoFlowButtonsStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 12
        return stackView
    }()
    
    lazy var timeStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    lazy var controllsButtonsStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.spacing = 8
        return stackView
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        self.backgroundColor = .clear
        createView()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
        createView()
    }
    
    func createView(){
        
        
        self.addSubview(videoFlowButtonsStackView)
        
        videoFlowButtonsStackView.addArrangedSubview(rewindButton)
        videoFlowButtonsStackView.addArrangedSubview(playButton)
        videoFlowButtonsStackView.addArrangedSubview(forwardButton)
        
        
        videoFlowButtonsStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        rewindButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo(60)
        }
        
        playButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo(60)
        }
        
        forwardButton.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo(60)
        }
        
        
        /* ----------- */
        
        self.addSubview(timeStackView)
        
        timeStackView.addArrangedSubview(currentTimeLabel)
        
        timeStackView.addArrangedSubview(seekSlider)
        
        timeStackView.addArrangedSubview(durationLabel)
        
        timeStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.height.equalTo(60)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        
        currentTimeLabel.snp.makeConstraints { make in
            make.width.equalTo(100)
        }
        
        seekSlider.isContinuous = true
        
        durationLabel.snp.makeConstraints { make in
            make.width.equalTo(100)
        }
        
        
        /* ----------- */
        
        
        self.addSubview(controllsButtonsStackView)
        
        controllsButtonsStackView.addArrangedSubview(closeButton)
        controllsButtonsStackView.addArrangedSubview(qaulityButton)
        controllsButtonsStackView.addArrangedSubview(subtitleButton)
        controllsButtonsStackView.addArrangedSubview(queueButton)
        controllsButtonsStackView.addArrangedSubview(expandButton)
        
        
        controllsButtonsStackView.snp.makeConstraints { make in
            make.trailing.equalTo(self.safeAreaLayoutGuide.snp.trailingMargin).inset(16)
            make.top.equalToSuperview().inset(16)
        }
        
        closeButton.snp.makeConstraints { make in
            make.height.equalTo(43)
            make.width.equalTo(43)
        }
        
        qaulityButton.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
        
        subtitleButton.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
        
        queueButton.snp.makeConstraints { make in
            make.height.equalTo(27)
            make.width.equalTo(30)
        }
        
        expandButton.snp.makeConstraints { make in
            make.height.equalTo(26)
            make.width.equalTo(29)
        }
        
    }
    
    
    @objc func playeVideo(_ sender: UIButton){
        player?.play()
    }
    
    @objc func rewindVideo(_ sender: UIButton){
        player?.rewind()
    }
    
    @objc func forwardVideo(_ sender: UIButton){
        player?.forward()
    }
    
    @objc func seekBarValueChanged(_ sender: UISlider){
        let targetTime:CMTime = CMTime(
            seconds: Double(sender.value),
            preferredTimescale: CMTimeScale(NSEC_PER_SEC)
        )
        
        self.player?.seek(value: targetTime)
    }
    
    @objc func seekBarTouchDown(_ sender: UISlider){
        player?.play()
    }
    
    @objc func seekBarTouchCancel(_ sender: UISlider){
        player?.play()
    }
    
    func changePlayStatus(isPlaying: Bool) {
        if isPlaying {
            playButton.setImage(UIImage(named:"ic_pause") ?? UIImage(), for: .normal)
        }else{
            playButton.setImage(UIImage(named:"ic_play") ?? UIImage(), for: .normal)
        }
    }
    
    func setCurrentTime(currentTime: String) {
        currentTimeLabel.text = currentTime
    }
    
    func setDuration(duration: String) {
        durationLabel.text = duration
    }
    
    func setSliderMax(maxProgress: Float) {
        seekSlider.maximumValue = maxProgress
    }
    
    func changeSliderProgress(progress: Float) {
        seekSlider.value = progress
    }
    
    @objc func closePlayer(_ sender: UIButton){
        player?.closePlayer()
        playerViewController?.exitPlayer()
    }
    
    @objc func showQaulities(_ sender: UIButton){
        if qaulitySegmentedControl?.isHidden ?? true {
            qaulitySegmentedControl?.isHidden = false
            subtitleSegmentedControl?.isHidden = true
            queueScrollView?.isHidden = true
        }else{
            qaulitySegmentedControl?.isHidden = true
        }
    }
    
    @objc func showSubtitle(_ sender: UIButton){
        if subtitleSegmentedControl?.isHidden ?? true {
            subtitleSegmentedControl?.isHidden = false
            qaulitySegmentedControl?.isHidden = true
            queueScrollView?.isHidden = true
        }else{
            subtitleSegmentedControl?.isHidden = true
        }
    }
    
    @objc func showQueue(_ sender: UIButton){
        if queueScrollView?.isHidden ?? true {
            queueScrollView?.isHidden = false
            qaulitySegmentedControl?.isHidden = true
            subtitleSegmentedControl?.isHidden = true
        }else{
            queueScrollView?.isHidden = true
        }
    }
    
    @objc func showExpand(_ sender: UIButton){
        if player?.videoGravity() == AVLayerVideoGravity.resizeAspect {
            player?.changeVideoGravity(videoGravity: .resizeAspectFill)
        }else{
            player?.changeVideoGravity(videoGravity: .resizeAspect)
        }
    }
    
    func createQaulitiesSegmentedControl(_ items:[String], selectedIndex:Int) {
        qaulitySegmentedControl = UISegmentedControl(items: items)
        qaulitySegmentedControl?.tintColor = .white
        qaulitySegmentedControl?.selectedSegmentIndex = selectedIndex
        qaulitySegmentedControl?.addTarget(self, action: #selector(DXPlayerControllView.segmentedControlQaulitiesValueChanged(_:)), for: .valueChanged)
        
        if qaulitySegmentedControl != nil {
            self.addSubview(qaulitySegmentedControl!)
        }
        
        qaulitySegmentedControl?.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.topMargin).inset(16)
        }
        
        qaulitySegmentedControl?.isHidden = true
        
    }
    
    
    @objc func segmentedControlQaulitiesValueChanged(_ sender: UISegmentedControl){
        player?.changeQuality(index: sender.selectedSegmentIndex)
    }
    
    func createSubtitleSegmentedControl(_ items:[String], selectedIndex:Int) {
        subtitleSegmentedControl = UISegmentedControl(items: items)
        subtitleSegmentedControl?.tintColor = .white
        subtitleSegmentedControl?.selectedSegmentIndex = selectedIndex
        subtitleSegmentedControl?.addTarget(self, action: #selector(DXPlayerControllView.segmentedControlSubtitleValueChanged(_:)), for: .valueChanged)
        
        if subtitleSegmentedControl != nil {
            self.addSubview(subtitleSegmentedControl!)
        }
        
        subtitleSegmentedControl?.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.topMargin).inset(16)
        }
        
        subtitleSegmentedControl?.isHidden = true
    }
    
    
    @objc func segmentedControlSubtitleValueChanged(_ sender: UISegmentedControl){
        player?.changeSubtitleSetting(index: sender.selectedSegmentIndex)
    }
    
    func clearSegmentedControl(){
        subtitleSegmentedControl?.removeFromSuperview()
        qaulitySegmentedControl?.removeFromSuperview()
    }
    
    func createQueue(_ items:[String], selectedIndex:Int) {
        
        queueScrollView = UIScrollView()
        queueScrollView?.showsHorizontalScrollIndicator = true
        queueScrollView?.showsVerticalScrollIndicator = false
        
        
        queueStackView = UIStackView()
        queueStackView?.axis = .horizontal
        queueStackView?.alignment = .fill
        queueStackView?.distribution = .fill
        queueStackView?.spacing = 8
        
        if locale ?? "en" != "en"{
            queueScrollView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            queueStackView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        }
        
        
        self.addSubview(queueScrollView!)
        
        queueScrollView?.addSubview(queueStackView!)
        
        
        queueStackView?.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        queueScrollView?.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.topMargin).inset(16)
            make.leading.equalToSuperview().inset(100)
            make.trailing.equalToSuperview().inset(100)
            make.height.equalTo(45)
        }
        
        for (index, item) in items.enumerated() {
            let button = UIButton()
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 7
            button.layer.masksToBounds = true
            button.setTitle(" \(item) ", for: .normal)
            if index == selectedIndex {
                button.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            }
            button.setTitleColor(.white, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(DXPlayerControllView.changeAssetItem(_:)), for: .touchUpInside)
            
            queueStackView?.addArrangedSubview(button)
        }
        
        queueScrollView?.isHidden = true
        
    }
    
    
    @objc func changeAssetItem(_ sender: UIButton){
        
        queueStackView?.arrangedSubviews.forEach({ (view) in
            let button = view as! UIButton
            button.backgroundColor = .clear
        })
        
        sender.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        player?.changeAssetItem(index: sender.tag)
    }
    
    
}


