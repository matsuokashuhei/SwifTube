//
//  ChannelsViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/22.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit

class ChannelsViewController: ItemsViewController {

    var channels: [SwifTube.Channel] = []

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
        if segue.identifier == "showChannel" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let destinationViewController = segue.destinationViewController as ChannelViewController
                destinationViewController.channel = channels[indexPath.row]
            }
        }
    }

    override func search(#conditions: [String: String]) {
        if let keyword = conditions["keyword"] {
            searcher.search(keyword: keyword, completion: { (channels: [SwifTube.Channel]!, error: NSError!) in
                if let channels = channels {
                    self.channels = channels
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
}

extension ChannelsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell  = tableView.dequeueReusableCellWithIdentifier("ChannelTableViewCell", forIndexPath: indexPath) as ChannelTableViewCell
        let item = channels[indexPath.row]
        cell.configure(item)
        return cell
    }

}

extension ChannelsViewController: UITableViewDelegate {

    override func populateItems() {
        if populatingItems {
            return
        }
        populatingItems = true
        if let keyword = searchConditions["keyword"] {
            searcher.search(keyword: keyword, page: .Next) { (channels: [SwifTube.Channel]!, error: NSError!) in
                if let channels = channels {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        let lastIndex = self.channels.count
                        for channel in channels {
                            self.channels.append(channel)
                        }
                        let indexPaths = (lastIndex ..< self.channels.count).map { (transform: Int) -> NSIndexPath in
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