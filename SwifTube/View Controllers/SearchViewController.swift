//
//  SearchViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/22.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit
import Alamofire

class SearchViewController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var videosView: UIView!
    @IBOutlet var playlistsView: UIView!
    @IBOutlet var channelsView: UIView!

    var containerViews: [UIView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        containerViews = [videosView, playlistsView, channelsView]

        configure(segmentedControl)
        configure(searchBar)
    
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
    
    func configure(searchBar: UISearchBar) {
        searchBar.delegate = self
    }

    func segmentChanged(sender: UISegmentedControl) {
        for view in containerViews {
            view.hidden = true
        }
        containerViews[sender.selectedSegmentIndex].hidden = false
        
        searchBarSearchButtonClicked(searchBar)
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

extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if searchBar.text.isEmpty {
            return
        }
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let videosViewController = childViewControllers[segmentedControl.selectedSegmentIndex] as VideosViewController
            videosViewController.searchBarSearchButtonClicked(searchBar)
        case 1:
            let playlistsViewController = childViewControllers[segmentedControl.selectedSegmentIndex] as PlaylistsViewController
            playlistsViewController.searchBarSearchButtonClicked(searchBar)
        case 2:
            let channelsViewController = childViewControllers[segmentedControl.selectedSegmentIndex] as ChannelsViewController
            channelsViewController.searchBarSearchButtonClicked(searchBar)
        default:
            break
        }
    }

}