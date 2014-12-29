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
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var seekBar: SeekBar!
    
    var video: SwifTube.Video!
    var player: AVPlayer!
    var playerObserver: AnyObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = video.title
        
        // Do any additional setup after loading the view.
        video.streamURL(completion: { (streamURL, error) -> Void in
            if streamURL != nil {
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
            } else {
                println(error?.localizedDescription)
            }
        })
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
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "readyForDisplay" {
            // オブザーバーを消す。
            let playerLayer = playerView.layer as AVPlayerLayer
            playerLayer.removeObserver(self, forKeyPath: "readyForDisplay")
            // ボタン名をポーズにする。
            button.setTitle("Pause", forState: UIControlState.Normal)
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
            button.setTitle("Play", forState: UIControlState.Normal)
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
    
    //    @IBAction func playNextVideo() {
    //        if let videosViewController = navigationController?.viewControllers[0] as? VideosViewController {
    //            let videos = videosViewController.videos as NSArray
    //            let index = videos.indexOfObject(video)
    //            if index < videos.count - 1 {
    //                video = videos.objectAtIndex(index + 1) as Video
    //                self.viewDidLoad()
    //            }
    //        }
    //    }
    //
    //    @IBAction func playPreviciousVideo() {
    //        if let videosViewController = navigationController?.viewControllers[0] as? VideosViewController {
    //            let videos = videosViewController.videos as NSArray
    //            let index = videos.indexOfObject(video)
    //            if index > 0 {
    //                video = videos.objectAtIndex(index - 1) as Video
    //                self.viewDidLoad()
    //            }
    //        }
    //    }
    
    func onSliderValueChanged(sender: UISlider) {
        if player.rate > 0 {
            pauseVideo()
        }
        player.seekToTime(CMTimeMakeWithSeconds(Float64(sender.value), Int32(NSEC_PER_SEC)))
        playVideo()
    }
    
    func playVideo() {
        if player.rate == 0 && player.error == nil {
            player.play()
            button.setTitle("Pause", forState: UIControlState.Normal)
        }
    }
    
    func pauseVideo() {
        if player.rate > 0 && player.error == nil {
            player.pause()
            button.setTitle("Play", forState: UIControlState.Normal)
        }
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
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
