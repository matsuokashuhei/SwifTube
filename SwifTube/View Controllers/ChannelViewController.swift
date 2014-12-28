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

        // Do any additional setup after loading the view.
        containerViews = [videosView, playlistsView]

        navigationItem.title = channel.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        configure(segmentedControl)
        segmentChanged(segmentedControl)
        
        if let videosViewController = childViewControllers[0] as? VideosViewController {
            channel.videos { (items, error) -> Void in
                if let items = items {
                    dispatch_async(dispatch_get_main_queue()) {
                        videosViewController.videos = items
                    }
                }
            }
        }
        if let playlistsViewController = childViewControllers[1] as? PlaylistsViewController {
            channel.playlists { (items, error) -> Void in
                if let items = items {
                    dispatch_async(dispatch_get_main_queue()) {
                        playlistsViewController.playlists = items
                    }
                }
            }
        }
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
        switch sender.selectedSegmentIndex {
        case 0:
            if let videosViewController = childViewControllers[sender.selectedSegmentIndex] as? VideosViewController {
                channel.videos { (items, error) -> Void in
                    if let items = items {
                        dispatch_async(dispatch_get_main_queue()) {
                            videosViewController.videos = items
                            videosViewController.tableView.reloadData()
                        }
                    }
                }
            }
        case 1:
            if let playlistsViewController = childViewControllers[sender.selectedSegmentIndex] as? PlaylistsViewController {
                channel.playlists { (items, error) -> Void in
                    if let items = items {
                        dispatch_async(dispatch_get_main_queue()) {
                            playlistsViewController.playlists = items
                            playlistsViewController.tableView.reloadData()
                        }
                    }
                }
            }
        default:
            break
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
