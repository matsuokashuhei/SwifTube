//
//  ChannelsViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/22.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit

class ChannelsViewController: ItemsViewController {

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
                destinationViewController.channel = items[indexPath.row] as SwifTube.Channel
            }
        }
    }

    override func searchItems(#parameters: [String: String]) {
        super.searchItems(parameters: parameters)
        SwifTube.search(parameters: parameters) { (pageInfo: SwifTube.PageInfo!, channels: [SwifTube.Channel]!, error: NSError!) in
            self.searchItemsCompletion(pageInfo: pageInfo, items: channels, error: error)
        }
    }
    
    override func loadMoreItems() {
        super.loadMoreItems()
        SwifTube.search(parameters: searchParameters) { (pageInfo: SwifTube.PageInfo!, channels: [SwifTube.Channel]!, error: NSError!) in
            self.loadMoreItemsCompletion(pageInfo: pageInfo, items: channels, error: error)
        }
    }
}

extension ChannelsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < items.count {
            var cell  = tableView.dequeueReusableCellWithIdentifier("ChannelTableViewCell", forIndexPath: indexPath) as ChannelTableViewCell
            let item = items[indexPath.row] as SwifTube.Channel
            cell.configure(item)
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("LoadMoreTableViewCell", forIndexPath: indexPath) as LoadMoreTableViewCell
            cell.button.addTarget(self, action: "loadMoreItems", forControlEvents: UIControlEvents.TouchUpInside)
            return cell
        }
    }

}

extension ChannelsViewController: UITableViewDelegate {
}