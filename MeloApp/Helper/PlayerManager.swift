//
//  PlayerManager.swift
//  MeloApp
//
//  Created by Minh Tri on 12/28/20.
//

import AVFoundation
import AVKit

protocol PlayerManagerDelegate: class {
    func progressUpdated(_ playerManager: PlayerManager, at currentTime: Float64, per duration: Float64)
    
    func didFinishPlaying(_ playerManager: PlayerManager)
}

class PlayerManager {
    static let shared = PlayerManager()
    
    private var listPlayers: [AVPlayer?] = []
    private var listItems: [AVPlayerItem?] = []
    private var listObserver: [NSObject?] = []
    
    var currentItem: AVPlayerItem?
    var timeObserverTokens: [Any?] = []
    var isPlaying: Bool = false
    
    weak var delegate: PlayerManagerDelegate?
    
    private init() {}

    func addPlayerItem(item: AVPlayerItem, observer: NSObject) -> AVPlayerLayer? {
        if !listItems.contains(item) {
            let player = AVPlayer(playerItem: item)
            
            listPlayers.append(player)
            listItems.append(item)
            listObserver.append(observer)
            
            return AVPlayerLayer(player: player)
        }
        
        if let index = listItems.firstIndex(of: item) {
            return AVPlayerLayer(player: listPlayers[index])
        }
        
        return nil
    }
    
    func getPlayer(by item: AVPlayerItem?) -> AVPlayer? {
        if let index = listItems.firstIndex(of: item) {
            return listPlayers[index]
        }
        
        return nil
    }
    
    func removePlayerItem(_ item: AVPlayerItem, _ observer: NSObject) {
        if let index = listItems.firstIndex(of: item) {
            pause(with: item)

            listPlayers[index]!.replaceCurrentItem(with: nil)
            listPlayers[index] = nil
            listObserver[index] = nil
            listItems[index] = nil
            timeObserverTokens[index] = nil
            
            listItems.remove(at: index)
            listPlayers.remove(at: index)
            listObserver.remove(at: index)
            timeObserverTokens.remove(at: index)
        }
    }
    
    func clear() {
        for (index, _) in timeObserverTokens.enumerated() {
            if timeObserverTokens[index] != nil {
                pause(with: listItems[index]!)
            }

            listPlayers[index]!.replaceCurrentItem(with: nil)
            listPlayers[index] = nil
            listObserver[index] = nil
            listItems[index] = nil
            timeObserverTokens[index] = nil
        }
        
        listPlayers.removeAll()
        listItems.removeAll()
        listObserver.removeAll()
        timeObserverTokens.removeAll()
    }
    
    func play(with item: AVPlayerItem) {
        if let index = listItems.firstIndex(of: item) {
            if timeObserverTokens.indices.contains(index) && timeObserverTokens[index] != nil { return }
            
            let observer = listObserver[index]
            
            listPlayers[index]!.play()
            startObserve(item: item, observer!)
            
            listPlayers.forEach { (player) in
                if player!.currentItem! != item {
                    self.pause(with: player!.currentItem!)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PausePlayingVideo"), object: item)
                }
            }
        }
    }
    
    func pause(with item: AVPlayerItem) {
        if let index = listItems.firstIndex(of: item) {
            let observer = listObserver[index]
            
            listPlayers[index]!.pause()
            stopObserve(item: item, observer!)

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PausePlayingVideo"), object: item)
        }
    }
    
    func startObserve(item: AVPlayerItem, _ observer: NSObject) {

        item.addObserver(
           observer,
           forKeyPath: #keyPath(AVPlayerItem.status),
            options: [.old, .new],
           context: nil
        )

        addPeriodicTimeObserver(item: item)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleFinishVideo(_:)), name: .AVPlayerItemDidPlayToEndTime, object: item)
    }
    
    func stopObserve(item: AVPlayerItem, _ observer: NSObject) {
        guard let index = listItems.firstIndex(of: item) else { return }
        let timeObserverToken = timeObserverTokens[index]
        
        if timeObserverToken != nil {
            item.removeObserver(
                observer,
                forKeyPath: #keyPath(AVPlayerItem.status),
                context: nil
            )
            
//            item.removeObserver(
//                observer,
//                forKeyPath: "loadedTimeRanges",
//                context: nil
//            )
            
            removePeriodicTimeObserver(item: item)

            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: item)
        }
    }
    
    private func addPeriodicTimeObserver(item: AVPlayerItem) {
        guard let index = listItems.firstIndex(of: item) else { return }
        let player = listPlayers[index]
        
        // Notify every 1 / 60 second
        let time = CMTime(seconds: 1, preferredTimescale: 60)

        let timeObserverToken = player!.addPeriodicTimeObserver(
            forInterval: time,
            queue: .main) { progressTime in
     
            print("is playing")
            let duration = item.duration
            let currentTime = CMTimeGetSeconds(progressTime)
            let durationSec = CMTimeGetSeconds(duration)
            self.delegate?.progressUpdated(self, at: currentTime, per: durationSec)
        }
        
        if timeObserverTokens.indices.contains(index) {
            timeObserverTokens[index] = timeObserverToken
        } else {
            timeObserverTokens.append(timeObserverToken)
        }
    }
    
    private func removePeriodicTimeObserver(item: AVPlayerItem) {
        if let index = listItems.firstIndex(of: item) {

            let timeObserverToken = timeObserverTokens[index]
            listPlayers[index]!.removeTimeObserver(timeObserverToken!)
            timeObserverTokens[index] = nil
        }
    }
    
    @objc func handleFinishVideo(_ notifi: Notification) {
        delegate?.didFinishPlaying(self)
    }
}


