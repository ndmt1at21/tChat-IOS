//
//  VideoDetailViewController.swift
//  MeloApp
//
//  Created by Minh Tri on 12/27/20.
//

import UIKit
import AVFoundation
import AVKit
import Hero

class VideoDetailViewController: UIViewController {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var sliderTrack: UISlider!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    var urlVideo: URL?
    var imageThumbnail: UIImage?
    
    var player: AVPlayer?
    var layerPlayer: AVPlayerLayer?
    var timeObserverToken: Any?
    var isPlaying: Bool = false
    
    let loadingAnimation: LoadingIndicator = {
        let loading = LoadingIndicator(frame: .zero)
        loading.isTurnBlurEffect = false
        loading.colorIndicator = .white
        return loading
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sliderTrack.value = 0
        sliderTrack.isUserInteractionEnabled = false
        
        thumbnailImageView.image = imageThumbnail
        thumbnailImageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
       
        self.hero.isEnabled = true
        thumbnailImageView.hero.id = "cellVideo"
        
        self.hero.modalAnimationType = .fade
        navigationController?.hero.isEnabled = true
        navigationController?.hero.navigationAnimationType = .fade
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime, object: nil
        )
    }
    
    @objc func playerDidFinishPlaying(_ notifi: Notification) {
        isPlaying = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if layerPlayer != nil {
            layerPlayer!.frame = thumbnailImageView.bounds
        }

        thumbnailImageView.layoutIfNeeded()
        layerPlayer?.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        thumbnailImageView.addSubview(loadingAnimation)
        loadingAnimation.frame = thumbnailImageView.bounds
        loadingAnimation.startAnimation()
        
        setupVideo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        
        removePeriodicTimeObserver()
        player?.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges", context: nil)
        
        DispatchQueue.main.async {
            self.player?.pause()
            self.layerPlayer?.removeFromSuperlayer()
        }
    }
    
    func setupVideo() {
        
        guard let safeUrl = urlVideo else { return }

        player = AVPlayer(url: safeUrl)
        
        layerPlayer = AVPlayerLayer(player: player)
        layerPlayer?.frame = thumbnailImageView.bounds
        layerPlayer?.videoGravity = .resizeAspect
        
        thumbnailImageView.layer.addSublayer(layerPlayer!)
        
        player?.play()
        player?.addObserver(
            self,
            forKeyPath: "currentItem.loadedTimeRanges",
            options: .new,
            context: nil
        )
        
        addPeriodicTimeObserver()
    }
    
    func addPeriodicTimeObserver() {
        // Notify every 1 / 60 second
        let time = CMTime(seconds: 1, preferredTimescale: 60)

        timeObserverToken = player!.addPeriodicTimeObserver(
            forInterval: time,
            queue: .main) { progressTime in
     
            let currentTime = CMTimeGetSeconds(progressTime)
            
            // update currentTimeLabel
            self.currentTimeLabel.text = self.formatSecondToHour(Int(currentTime))
         
            // update sliderTrack
            if let duration = self.player?.currentItem?.duration {
                DispatchQueue.main.async {
                    let durationSeconds = CMTimeGetSeconds(duration)
                    self.sliderTrack.value = Float(currentTime / durationSeconds)
                }
            }
        }
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player!.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // player ready to play
        if keyPath == "currentItem.loadedTimeRanges" {
            
            loadingAnimation.stopAnimation()
            
            // not set slider, user use it before load -> value = nan
            isPlaying = true
            sliderTrack.isUserInteractionEnabled = true
            thumbnailImageView.image = nil
           
            // set total label time
            if let duration = player?.currentItem?.duration {
                let seconds = CMTimeGetSeconds(duration)
                totalTimeLabel.text = formatSecondToHour(Int(seconds))
            }
        }
    }
    
    private func formatSecondToHour(_ timeInSeconds: Int) -> String {
        let hours = timeInSeconds / 3600
        let minutes = timeInSeconds / 60 % 60
        let seconds = timeInSeconds % 60
        
        if hours == 0 {
            return String(format:"%02i:%02i", minutes, seconds)
        } else {
            return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        }
    }
    
    
    @IBAction func sliderChangedValue(_ sender: UISlider) {
        
        if let duration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            
            let value = Float64(sliderTrack.value) * totalSeconds
            let seekTime = CMTime(value: Int64(value) * 60, timescale: 60)
            
            player?.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
            
            if !isPlaying {
                player?.play()
                isPlaying = true
            }
        }
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        
        var imageName: String = ""
        if isPlaying {
            player?.pause()
            imageName = "play.fill"
        } else {
            player?.play()
            imageName = "pause.fill"
        }
        
        isPlaying = !isPlaying
        DispatchQueue.main.async {
            self.pauseButton.setBackgroundImage(UIImage(systemName: imageName), for: .normal)
        }
    }
}
