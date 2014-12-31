//
//  VideoPlayerView.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/31.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit
import AVFoundation

protocol MovieViewDelegate {
    func willStartPlaying(sender: MovieView, item: AVPlayerItem)
    func playAtTime(sender: MovieView, time: CMTime, duration: CMTime)
    func didPlayToEndTime(sender: MovieView)
}

class MovieView: UIView {
    
    let log = XCGLogger.defaultInstance()

    var item: AVPlayerItem?
    var player: AVPlayer?
    var delegate: MovieViewDelegate?
    var periodicTimeObserver: AnyObject?
    var playing = false

    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }

    /**
    再生の準備
    */
    func prepareToPlay(URL: NSURL) {
        log.debug("URL: \(URL)")
        // AVPlayerItemの作成
        if let item = self.item {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
        }
        item = AVPlayerItem(URL: URL)
        // AVPlayerの作成
        if let player = self.player {
            player.replaceCurrentItemWithPlayerItem(item)
        } else {
            player = AVPlayer(playerItem: item)
        }
        // APLayerLayerの作成
        let playerLayer = self.layer as AVPlayerLayer
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        playerLayer.player = player
        // 準備の終了をお知らせするノーティフィケーションの登録
        playerLayer.addObserver(self, forKeyPath: "readyForDisplay", options: NSKeyValueObservingOptions.New, context: nil)
    }

    // ノーティフィケーションの受け取り
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        log.debug("keyPath: \(keyPath), object: \(object), change: \(change), context: \(context)")
        // AVPlayerItemの作成
        if keyPath == "readyForDisplay" {
            // オブザーバーの削除
            let playerLayer = self.layer as AVPlayerLayer
            playerLayer.removeObserver(self, forKeyPath: "readyForDisplay")
            startPlay()
        }
    }

    /**
    再生の開始
    */
    func startPlay() {
        log.debug("")
        // 再生の開始のデリゲート
        delegate?.willStartPlaying(self, item: item!)
        // 再生
        play()
        // 再生中の経過時間を通知するノーティフィケーションの登録
        if let player = self.player {
            if let item = self.item {
                let second = CMTimeMakeWithSeconds(1, Int32(NSEC_PER_SEC))
                periodicTimeObserver = player.addPeriodicTimeObserverForInterval(second, queue: nil) { (time: CMTime) in
                    self.playingAtTime(time)
                }
            }
        }
        // 再生の終わりをお知らせするノーティフィケーションの登録
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemDidPlayToEndTime:", name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
    }

    /**
    再生中の経過時間の通知
    */
    func playingAtTime(time: CMTime) {
        log.debug("time: \(time)")
        if let item = item {
            delegate?.playAtTime(self, time: time, duration: item.duration)
        }
    }

    /**
    再生
    */
    func play() {
        log.debug("player: \(player)")
        if let player = player {
            player.play()
            playing = true
        }
    }

    /**
    停止
    */
    func pause() {
        log.debug("player: \(player)")
        if let player = player {
            player.pause()
            playing = false
        }
    }

    /**
    再生の終わりの動作
    */
    func itemDidPlayToEndTime(notification: NSNotification) {
        log.debug("notification: \(notification)")
        player?.seekToTime(kCMTimeZero)
        delegate?.didPlayToEndTime(self)
    }

    /**
    全てのクリアー
    */
    func clear() {
        log.debug("")
        if let player = player {
            log.debug("player: \(player)")
            pause()
            player.removeTimeObserver(self.periodicTimeObserver)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
            let layer = self.layer as AVPlayerLayer
            layer.player = nil
            item = nil
            periodicTimeObserver = nil
        }
    }

    /**
    再生位置の変更
    */
    func seekToSeconds(seconds: Float) {
        log.debug("seconds: \(seconds)")
        let time = CMTimeMakeWithSeconds(Float64(seconds), Int32(NSEC_PER_SEC))
        if let player = player {
            player.seekToTime(time)
        }
    }
    
}