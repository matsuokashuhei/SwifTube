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
    
    let log = XCGLogger.defaultInstance()

    @IBOutlet weak var movieView: MovieView!
    @IBOutlet weak var seekBar: SeekBar!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var video: SwifTube.Video!
    var delegate: VideoPlayerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(seekBar: seekBar)
        configure(prevButton: prevButton, playButton: playButton, nextButton: nextButton)
        

        video.streamURL(completion: { (streamURL, error) -> Void in
            if let URL = streamURL {
                self.movieView.delegate = self
                self.movieView.prepareToPlay(URL)
            }
        })
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        movieView.clear()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func configure(#seekBar: SeekBar) {
        log.debug("seekBar: \(seekBar)")
        seekBar.slider.addTarget(self, action: "onSliderValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
    }

    func configure(#prevButton: UIButton, playButton: UIButton, nextButton: UIButton) {
        log.debug("prevButton: \(prevButton), playButton: \(playButton), nextButton: \(nextButton)")
        // Prev Button
        prevButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 20)
        prevButton.setTitle(NSString.awesomeIcon(FaBackward), forState: .Normal)
        // Play/Pause Button
        playButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 30)
        playButton.setTitle(NSString.awesomeIcon(FaPlay), forState: .Normal)
        // Next Button
        nextButton.titleLabel?.font = UIFont(name: "FontAwesome", size: 20)
        nextButton.setTitle(NSString.awesomeIcon(FaForward), forState: .Normal)
        //
        if let delegate = delegate {
            if delegate.canPlayPrevVideo(self) {
                prevButton.setTitle(NSString.awesomeIcon(FaBackward), forState: .Normal)
            } else {
                prevButton.setTitle(NSString.awesomeIcon(FaBackward), forState: .Disabled)
                prevButton.setTitleColor(UIColor.blackColor(), forState: .Disabled)
            }
            if delegate.canPlayNextVideo(self) {
                nextButton.setTitle(NSString.awesomeIcon(FaForward), forState: .Normal)
            } else {
                nextButton.setTitle(NSString.awesomeIcon(FaForward), forState: .Disabled)
                nextButton.setTitleColor(UIColor.blackColor(), forState: .Disabled)
            }
        }
    }

    func onSliderValueChanged(sender: UISlider) {
        log.debug("sender: \(sender)")
        movieView.pause()
        movieView.seekToSeconds(sender.value)
        movieView.play()
    }

    @IBAction func clickButton(sender: UIButton) {
        log.debug("sender: \(sender)")
        if movieView.playing {
            movieView.pause()
            playButton.setTitle(NSString.awesomeIcon(FaPlay), forState: .Normal)
        } else {
            movieView.play()
            playButton.setTitle(NSString.awesomeIcon(FaPause), forState: .Normal)
        }
    }
    
    @IBAction func playNextVideo() {
        log.debug("")
        delegate?.playNextVideo(self)
    }
    
    
    @IBAction func playPrevVideo() {
        log.debug("")
        delegate?.playPrevVideo(self)
    }

}

extension VideoViewController: MovieViewDelegate {
    
    func willStartPlaying(sender: MovieView, item: AVPlayerItem) {
        log.debug("sender: \(sender), item: \(item)")
        navigationItem.title = video.title
        seekBar.configure(item.duration)
        playButton.setTitle(NSString.awesomeIcon(FaPause), forState: .Normal)
    }

    func playAtTime(sender: MovieView, time: CMTime, duration: CMTime) {
        log.debug("sender: \(sender), time: \(time), duration: \(duration)")
        self.seekBar.setTime(time, duration: duration)
    }

    func didPlayToEndTime(sender: MovieView) {
        log.debug("sender: \(sender)")
        playButton.setTitle(NSString.awesomeIcon(FaPlay), forState: .Normal)
        if let delegate = delegate {
            if delegate.canPlayNextVideo(self) {
                delegate.playNextVideo(self)
            }
        }
    }

}

protocol VideoPlayerDelegate {
    func canPlayNextVideo(videoPlayerController: VideoViewController) -> Bool
    func canPlayPrevVideo(videoPlayerController: VideoViewController) -> Bool
    func playNextVideo(videoPlayerController: VideoViewController)
    func playPrevVideo(videoPlayerController: VideoViewController)
}