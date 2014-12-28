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
    var videos: [SwifTube.Video] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = playlist.title

        // Do any additional setup after loading the view.
        playlist.videos() { (videos: [SwifTube.Video]!, error: NSError!) in
            if let videos = videos {
                self.videos = videos
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
                destinationViewController.video = videos[indexPath.row]
            }
        }
    }

}

extension PlaylistViewController: UITableViewDataSource {
    
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