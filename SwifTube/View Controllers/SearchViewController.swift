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

        containerViews = [videosView, playlistsView, channelsView]
        
        configure(navigationItem: navigationItem)
        configure(segmentedControl: segmentedControl)
        configure(searchBar: searchBar)
        configure(containerViews: containerViews)
        segmentChanged(segmentedControl)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configure(#navigationItem: UINavigationItem) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }

    func configure(#segmentedControl: UISegmentedControl) {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: Selector("segmentChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }

    func configure(#containerViews: [UIView]) {
        for view in containerViews {
            view.hidden = true
        }
        containerViewAtSelectedSegmentIndex().hidden = false
    }

    func configure(#searchBar: UISearchBar) {
        //searchBar.delegate = self
        searchBar.delegate = itemViewControllerAtSelectedSegmentIndex()
    }
    
    func segmentChanged(sender: UISegmentedControl) {
        configure(containerViews: containerViews)
        searchBar.delegate = itemViewControllerAtSelectedSegmentIndex()
        searchBar.delegate!.searchBarSearchButtonClicked!(searchBar)
    }

    func containerViewAtSelectedSegmentIndex() -> UIView {
        return containerViews[segmentedControl.selectedSegmentIndex]
    }

    func itemViewControllerAtSelectedSegmentIndex() -> ItemsViewController {
        return childViewControllers[segmentedControl.selectedSegmentIndex] as ItemsViewController
    }
}
