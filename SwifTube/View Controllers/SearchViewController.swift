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
    @IBOutlet var containerView: UIView!

    var itemsViewControllers: [ItemsViewController]!
    var currentItemsViewController: ItemsViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configure(segmentedControl)
        configure(searchBar)

        itemsViewControllers = [
            storyboard?.instantiateViewControllerWithIdentifier("VideosViewController") as VideosViewController,
            storyboard?.instantiateViewControllerWithIdentifier("PlaylistsViewController") as PlaylistsViewController,
            storyboard?.instantiateViewControllerWithIdentifier("ChannelsViewController") as ChannelsViewController,
        ]
        configure(itemsViewControllers)
        currentItemsViewController = viewControllerForSegmentIndex()

        configure(containerView)
    
        segmentChanged(segmentedControl)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
    
    func configure(itemsViewControllers: [ItemsViewController]) {
        for itemsViewController in itemsViewControllers {
            addChildViewController(itemsViewController)
            configure(itemsViewController)
        }
    }

    func configure(itemsViewController: ItemsViewController) {
        itemsViewController.view.frame = containerView.bounds
    }
    
    func configure(containerView: UIView) {
        for subview in containerView.subviews {
            subview.removeFromSuperview()
        }
        containerView.addSubview(currentItemsViewController.view)
    }
    
    func segmentChanged(sender: UISegmentedControl) {
        var itemsViewController = viewControllerForSegmentIndex()
        transitionFromViewController(currentItemsViewController, toViewController: itemsViewController, duration: 0, options: UIViewAnimationOptions.TransitionNone, animations: nil) { (finished) -> Void in
            self.currentItemsViewController = itemsViewController
            self.configure(self.containerView)
        }
        searchBarSearchButtonClicked(searchBar)
    }

    func viewControllerForSegmentIndex() -> ItemsViewController {
        return itemsViewControllers[segmentedControl.selectedSegmentIndex]
    }

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