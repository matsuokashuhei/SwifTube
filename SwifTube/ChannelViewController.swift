//
//  ChannelViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/25.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit

class ChannelViewController: UIViewController {

    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var videosView: UIView!
    @IBOutlet var playlistsView: UIView!

    var containerViews: [UIView] = []

    var channel: SwifTube.Channel!
    var videos: [SwifTube.Video]!
    var playlists: [SwifTube.Playlist]!

    override func viewDidLoad() {
        super.viewDidLoad()

        channel.videos { (videos, error) -> Void in
            if let videos = videos {
                self.videos = videos
//                dispatch_async(dispatch_get_main_queue()) {
//                    self.tableView.reloadData()
//                }
            }
        }
        // Do any additional setup after loading the view.
        containerViews = [videosView, playlistsView,]
        configure(segmentedControl)
        segmentChanged(segmentedControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure(segmentedControl: UISegmentedControl) {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: Selector("segmentChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func segmentChanged(sender: UISegmentedControl) {
        for view in containerViews {
            view.hidden = true
        }
        containerViews[sender.selectedSegmentIndex].hidden = false
        //println("containerViews[\(sender.selectedSegmentIndex)].hidden = false")
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
