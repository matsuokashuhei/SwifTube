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

        searchItems(parameters: ["playlistId": playlist.id])
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func configure(#navigationItem: UINavigationItem) {
        navigationItem.title = playlist.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
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
                destinationViewController.delegate = self
            }
        }
    }

    override func searchItems(#parameters: [String: String]) {
        super.searchItems(parameters: parameters)
        SwifTube.playlistItems(parameters: parameters) { (pageInfo: SwifTube.PageInfo!, videos: [SwifTube.Video]!, error: NSError!) in
            self.searchItemsCompletion(pageInfo: pageInfo, items: videos, error: error)
        }
    }
    
    override func loadMoreItems() {
        super.loadMoreItems()
        SwifTube.playlistItems(parameters: searchParameters) { (pageInfo: SwifTube.PageInfo!, videos: [SwifTube.Video]!, error: NSError!) in
            self.loadMoreItemsCompletion(pageInfo: pageInfo, items: videos, error: error)
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
            cell.button.addTarget(self, action: "loadMoreItems", forControlEvents: UIControlEvents.TouchUpInside)
            return cell
        }
    }

}

extension PlaylistViewController: UITableViewDelegate {
}

extension PlaylistViewController: VideoPlayerDelegate {

    func canPlayNextVideo(videoViewController: VideoViewController) -> Bool {
        let index = NSArray(array: items).indexOfObject(videoViewController.video)
        return index + 1 < items.count
    }

    func canPlayPrevVideo(videoViewController: VideoViewController) -> Bool {
        let index = NSArray(array: items).indexOfObject(videoViewController.video)
        return index > 0
    }

    func playNextVideo(videoViewController: VideoViewController) {
        let index = NSArray(array: items).indexOfObject(videoViewController.video)
        if index + 1 < items.count {
            let nextVideo = items[index + 1] as SwifTube.Video
            videoViewController.video = nextVideo
            videoViewController.viewDidLoad()
        }
    }
    
    func playPrevVideo(videoViewController: VideoViewController) {
        let index = NSArray(array: items).indexOfObject(videoViewController.video)
        if index > 0 {
            let prevVideo = items[index - 1] as SwifTube.Video
            videoViewController.video = prevVideo
            videoViewController.viewDidLoad()
        }
    }
}
