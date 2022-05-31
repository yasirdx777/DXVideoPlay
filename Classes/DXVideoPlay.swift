//
//  DXVideoPlay.swift
//  Yasir N.Ramaya
//
//  Created by Yasir N.Ramaya on 7/1/20.
//  Copyright © 2020 Yasir N.Ramaya. All rights reserved.
//

import UIKit
import AVKit

public class DXVideoPlay: UIViewController, DXPlayerViewControllerProtocol {
    
    public override var prefersStatusBarHidden: Bool { return true }
    
    var playerViewControll:DXPlayerControllView?
    var playerView:DXPlayer!
    var timer: DispatchSourceTimer?
    
    var playerModel: DXPlayerModel?
    
    
    public init(playerModel:DXPlayerModel) {
        self.playerModel = playerModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        }

        setupPlayerView()
        connectPlayerViews()
        setupPlayerViewControllVisibility()

        if let model = playerModel {
            startPlay(playerModel: model)
        }

        createTimer()
        

    }
    
    
    func exitPlayer() {
        stopTimer()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func setupPlayerView(){
        playerView = DXPlayer(frame: self.view.bounds)
        
        self.view.addSubview(playerView)
        
        playerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        
        playerViewControll = DXPlayerControllView(frame: self.view.bounds)
        
        self.view.addSubview(playerViewControll!)
        
        playerViewControll?.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
    }
    
    
    func setupPlayerViewControllVisibility() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
    }
    
    func createTimer() {
        timer = DispatchSource.makeTimerSource(queue: .main)
        timer?.schedule(deadline: .now() + 12, repeating: 1.0)

        timer?.setEventHandler { [weak self] in   self?.playerViewControll?.isHidden = true
            self?.stopTimer()
        }
        
        startTimer()
    }
    
    func startTimer() {
        timer?.resume()
    }

    func pauseTiemr() {
        timer?.suspend()
    }

    func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    func connectPlayerViews() {
        playerViewControll?.player = playerView
        playerViewControll?.playerViewController = self
        playerView.playerControll = playerViewControll
    }
    
    
    func startPlay(playerModel:DXPlayerModel) {
        playerView.initPlayer(playerModel: playerModel)
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if playerViewControll?.isHidden == false {
            playerViewControll?.isHidden = true
            stopTimer()
        }else{
            playerViewControll?.isHidden = false
            createTimer()
        }
    }
    
}
