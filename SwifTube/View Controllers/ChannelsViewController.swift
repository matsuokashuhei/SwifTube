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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configure(tableView: UITableView) {
        super.configure(tableView)
        tableView.dataSource = self
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showChannel" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let destinationViewController = segue.destinationViewController as ChannelViewController
                destinationViewController.channel = channels[indexPath.row]
            }
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

extension ChannelsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        SwifTube.search(keyword: searchBar.text, completion: { (channels: [SwifTube.Channel]!, error: NSError!) in
            if let channels = channels {
                self.channels = channels
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        })
    }

}