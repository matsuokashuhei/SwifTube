//
//  PlaylistsViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/22.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit

class PlaylistsViewController: ItemsViewController {

    var playlists: [SwifTube.Playlist] = []

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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPlaylist" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let destinationViewController = segue.destinationViewController as PlaylistViewController
                destinationViewController.playlist = playlists[indexPath.row]
            }
        }
    }
    
    override func search(#conditions: [String: String]) {
        if let keyword = conditions["keyword"] {
            searcher.search(keyword: keyword, completion: { (playlists: [SwifTube.Playlist]!, error: NSError!) in
                if let playlists = playlists {
                    self.playlists = playlists
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }

}

extension PlaylistsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell  = tableView.dequeueReusableCellWithIdentifier("PlaylistTableViewCell", forIndexPath: indexPath) as PlaylistTableViewCell
        let item = playlists[indexPath.row]
        cell.configure(item)
        return cell
    }

}

extension PlaylistsViewController: UITableViewDelegate {

    override func populateItems() {
        if populatingItems {
            return
        }
        populatingItems = true
        if let keyword = searchConditions["keyword"] {
            searcher.search(keyword: keyword, page: .Next) { (playlists: [SwifTube.Playlist]!, error: NSError!) in
                if let playlists = playlists {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        let lastIndex = self.playlists.count
                        for playlist in playlists {
                            self.playlists.append(playlist)
                        }
                        let indexPaths = (lastIndex ..< self.playlists.count).map { (transform: Int) -> NSIndexPath in
                            return NSIndexPath(forItem: transform, inSection: 0)
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
                            self.populatingItems = false
                        }
                    }
                }
            }
        }
    }

}