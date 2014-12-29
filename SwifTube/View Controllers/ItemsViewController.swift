//
//  ItemsViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/22.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit

class ItemsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!

    var items: [SwifTube.Item] = []

    var searchParameters = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(navigationItem: navigationItem)
        configure(tableView: tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configure(#navigationItem: UINavigationItem) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }

    func configure(#tableView: UITableView) {
        tableView.delegate = self
    }

    func search() {
    }
    func populateItems() {
    }
    
    func updateSearchParameters(#token: SwifTube.PageToken!) {
        if let token = token {
            if !token.next.isEmpty {
                searchParameters["pageToken"] = token.next
            } else {
                searchParameters["pageToken"] = ""
            }
        }
        println("searchParameters: \(searchParameters)")
    }

}

extension ItemsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count > 0 {
            if let nextPageToken = searchParameters["pageToken"] {
                if !nextPageToken.isEmpty {
                    return items.count + 1
                }
            }
        }
        return items.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row < items.count {
            return 100
        } else {
            return 50
        }
    }
}

extension ItemsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if searchBar.text.isEmpty {
            return
        }
        searchParameters = ["q": searchBar.text]
        search()
    }
    
}