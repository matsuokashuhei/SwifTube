//
//  PlaylistViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/25.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit

class PlaylistViewController: ItemsViewController {

    var playlist: SwifTube.Playlist!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = playlist.title

        // Do any additional setup after loading the view.
        searchParameters = ["playlistId": playlist.id]
        SwifTube.playlistItems(parameters: searchParameters) { (videos: [SwifTube.Video]!, token: SwifTube.PageToken!, error: NSError!) in
            if let videos = videos {
                self.updateSearchParameters(token: token)
                self.items = videos
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                destinationViewController.video = items[indexPath.row] as SwifTube.Video
            }
        }
    }

}

extension PlaylistViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < items.count {
            var cell = tableView.dequeueReusableCellWithIdentifier("VideoTableViewCell", forIndexPath: indexPath) as VideoTableViewCell
            let item = items[indexPath.row] as SwifTube.Video
            cell.configure(item)
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("LoadMoreTableViewCell", forIndexPath: indexPath) as LoadMoreTableViewCell
            cell.button.addTarget(self, action: "populateItems", forControlEvents: UIControlEvents.TouchUpInside)
            return cell
        }
    }

    override func populateItems() {
        SwifTube.playlistItems(parameters: searchParameters) { (videos: [SwifTube.Video]!, token: SwifTube.PageToken!, error: NSError!) in
            if let videos = videos {
                self.updateSearchParameters(token: token)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    let lastIndex = self.items.count
                    for video in videos {
                        self.items.append(video)
                    }
                    let indexPaths = (lastIndex ..< self.items.count).map { (transform: Int) -> NSIndexPath in
                        return NSIndexPath(forItem: transform, inSection: 0)
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
                    }
                }
            }
        }
    }
}

extension PlaylistViewController: UITableViewDelegate {
}