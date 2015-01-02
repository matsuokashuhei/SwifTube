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

    let logger = XCGLogger.defaultInstance()

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

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
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
        itemViewControllerAtSelectedSegmentIndex().tableView.delegate = self
    }

    func configure(#searchBar: UISearchBar) {
        searchBar.delegate = itemViewControllerAtSelectedSegmentIndex()
        searchBar.becomeFirstResponder()
        
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

extension SearchViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }

//    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        let endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height
//        logger.debug("endScrolling: \(endScrolling), scrollView.contentSize.height: \(scrollView.contentSize.height)")
//        if endScrolling >= scrollView.contentSize.height {
//            itemViewControllerAtSelectedSegmentIndex().loadMoreItems()
//        }
//    }

}

extension SearchViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchBar.resignFirstResponder()
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return itemViewControllerAtSelectedSegmentIndex().tableView(tableView, heightForRowAtIndexPath: indexPath)
    }

}
