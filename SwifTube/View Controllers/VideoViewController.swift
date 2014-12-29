//
//  VideoViewController.swift
//  YouTubeApp
//
//  Created by matsuosh on 2014/12/20.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit
import AVFoundation

class VideoViewController: UIViewController {
    
    @IBOutlet weak var playerView: AVPlayerView!
    @IBOutlet weak var seekBar: SeekBar!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var video: SwifTube.Video!
    var player: AVPlayer!
    var playerObserver: AnyObject!
    
    var delegate: VideoPlayerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showVideo()
    }
    
    override func viewDidDisappear(animated: Bool) {
        if let observer: AnyObject = playerObserver {
            player.removeTimeObserver(observer)
        }
        pauseVideo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configurePlayerController() {
        if let delegate = delegate {
            prevButton.enabled = delegate.canPlayPrevVideo(self) ? true : false
            nextButton.enabled = delegate.canPlayNextVideo(self) ? true : false
        }
        
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "readyForDisplay" {
            // オブザーバーを消す。
            let playerLayer = playerView.layer as AVPlayerLayer
            playerLayer.removeObserver(self, forKeyPath: "readyForDisplay")
            // ボタン名をポーズにする。
            playButton.setTitle("Pause", forState: UIControlState.Normal)
            // シークバーに時間を入れる。
            configureSeekBar(player.currentItem)
            // 動画を再生する。
            player.play()
            // タイマーをONにする。
            addPeriodicTimeObserverForInterval()
        }
    }
    
    func playerItemDidPlayToEndTime(notification: NSNotification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playButton.setTitle("Play", forState: UIControlState.Normal)
        }
    }

    func configureSeekBar(playerItem: AVPlayerItem) {
        seekBar.configure(playerItem.duration)
    }

    func addPeriodicTimeObserverForInterval() {
        let time = CMTimeMakeWithSeconds(1, Int32(NSEC_PER_SEC))
        playerObserver = self.player.addPeriodicTimeObserverForInterval(time, queue: nil) { (time) -> Void in
            self.seekBar.setTime(time, duration: self.player.currentItem.duration)
        }
    }
    
    func showVideo() {
        configurePlayerController()
        navigationItem.title = video.title
        video.streamURL(completion: { (streamURL, error) -> Void in
            if let streamURL = streamURL {
                // Playerの作成
                var playerItem = AVPlayerItem(asset: AVURLAsset(URL: streamURL, options: nil))
                self.player = AVPlayer(playerItem: playerItem)
                // PlayerLayerの作成
                var playerLayer = self.playerView.layer as AVPlayerLayer
                playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
                playerLayer.player = self.player
                // オブザーバーの登録
                playerLayer.addObserver(self, forKeyPath: "readyForDisplay", options: NSKeyValueObservingOptions.New, context: nil)
                // シークバーのイベンントの登録
                self.seekBar.slider.addTarget(self, action: "onSliderValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
            }
        })
    }
    
    @IBAction func clickButton(sender: UIButton) {
        if player.rate > 0 && player.error == nil {
            pauseVideo()
            return
        }
        if player.rate == 0 && player.error == nil {
            playVideo()
            return
        }
    }
    
    @IBAction func playNextVideo() {
        delegate?.playNextVideo(self)
    }
    
    
    @IBAction func playPrevVideo() {
        delegate?.playPrevVideo(self)
    }
    
    func onSliderValueChanged(sender: UISlider) {
        if player.rate > 0 {
            pauseVideo()
        }
        player.seekToTime(CMTimeMakeWithSeconds(Float64(sender.value), Int32(NSEC_PER_SEC)))
        playVideo()
    }
    
    func playVideo() {
        if let player = player {
            if player.rate == 0 && player.error == nil {
                player.play()
                playButton.setTitle("Pause", forState: UIControlState.Normal)
            }
        }
    }
    
    func pauseVideo() {
        if let player = player {
            if player.rate > 0 && player.error == nil {
                player.pause()
                playButton.setTitle("Play", forState: UIControlState.Normal)
            }
        }
    }
    
}

class AVPlayerView: UIView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }
    
}

protocol VideoPlayerDelegate {
    func canPlayNextVideo(videoPlayerController: VideoViewController) -> Bool
    func canPlayPrevVideo(videoPlayerController: VideoViewController) -> Bool
    func playNextVideo(videoPlayerController: VideoViewController)
    func playPrevVideo(videoPlayerController: VideoViewController)
}