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

    override func viewDidLoad() {
        super.viewDidLoad()

        containerViews = [videosView, playlistsView]

        navigationItem.title = channel.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        configure(segmentedControl)
        segmentChanged(segmentedControl)
        
        if let videosViewController = childViewControllers[0] as? VideosViewController {
            videosViewController.searchItems(parameters: ["channelId": self.channel.id])
        }
        if let playlistsViewController = childViewControllers[1] as? PlaylistsViewController {
            playlistsViewController.searchItems(parameters: ["channelId": self.channel.id])
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        switch sender.selectedSegmentIndex {
        case 0:
            if let videosViewController = childViewControllers[sender.selectedSegmentIndex] as? VideosViewController {
                videosViewController.searchItems(parameters: ["channelId": self.channel.id])
            }
        case 1:
            if let playlistsViewController = childViewControllers[sender.selectedSegmentIndex] as? PlaylistsViewController {
                playlistsViewController.searchItems(parameters: ["channelId": self.channel.id])
            }
        default:
            break
        }
    }

}
