//
//  VideosViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/22.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit

class VideosViewController: ItemsViewController {

    var videos: [SwifTube.Video] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func configure(#tableView: UITableView) {
        super.configure(tableView: tableView)
        tableView.dataSource = self
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showVideo" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let destinationViewController = segue.destinationViewController as VideoViewController
                destinationViewController.video = videos[indexPath.row]
            }
        }
    }

    override func search(#conditions: [String: String]) {
        if let keyword = conditions["keyword"] {
            searcher.search(keyword: keyword, completion: { (videos: [SwifTube.Video]!, error: NSError!) in
                if let videos = videos {
                    self.videos = videos
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
}

extension VideosViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell  = tableView.dequeueReusableCellWithIdentifier("VideoTableViewCell", forIndexPath: indexPath) as VideoTableViewCell
        let item = videos[indexPath.row]
        cell.configure(item)
        return cell
    }

}

extension VideosViewController: UITableViewDelegate {

    override func populateItems() {
        if populatingItems {
            return
        }
        populatingItems = true
        if let keyword = searchConditions["keyword"] {
            searcher.search(keyword: keyword, page: .Next) { (videos: [SwifTube.Video]!, error: NSError!) in
                if let videos = videos {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        let lastIndex = self.videos.count
                        for video in videos {
                            self.videos.append(video)
                        }
                        let indexPaths = (lastIndex ..< self.videos.count).map { (transform: Int) -> NSIndexPath in
                            return NSIndexPath(forItem: transform, inSection: 0)
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
                            //self.tableView.reloadData()
                            self.populatingItems = false
                        }
                    }
                }
            }
        }
    }

}
