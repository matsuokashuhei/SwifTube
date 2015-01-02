//
//  ItemsViewController.swift
//  SwifTube
//
//  Created by matsuosh on 2014/12/22.
//  Copyright (c) 2014年 matsuosh. All rights reserved.
//

import UIKit

class ItemsViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet var tableView: UITableView!
    let refreshControll = UIRefreshControl()

    var items: [SwifTube.Item] = []

    var searchParameters = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(navigationItem: navigationItem)
        configure(tableView: tableView)

        refreshControll.addTarget(self, action: "pullToRefresh", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControll)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func configure(#navigationItem: UINavigationItem) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }

    func configure(#tableView: UITableView) {
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
        tableView.delegate = self
    }

    func searchItems(#parameters: [String: String]) {
        SVProgressHUD.show()
        searchParameters = parameters
    }

    func loadMoreItems() {
        SVProgressHUD.show()
    }

    func setTokenToSearchParameters(#pageInfo: SwifTube.PageInfo!) {
        if let pageInfo = pageInfo {
            searchParameters["pageToken"] = pageInfo.nextPageToken
        }
    }

    func searchItemsCompletion(#pageInfo: SwifTube.PageInfo, items: [SwifTube.Item]!, error: NSError!) {
        if let items = items {
            Async.background {
                self.setTokenToSearchParameters(pageInfo: pageInfo)
                self.items = items
            }.main {
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }
        }
    }

    func loadMoreItemsCompletion(#pageInfo: SwifTube.PageInfo, items: [SwifTube.Item]!, error: NSError!) {
        if let items = items {
            self.setTokenToSearchParameters(pageInfo: pageInfo)
            Async.background {
                for item in items {
                    self.items.append(item)
                }
            }.main {
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }
        }
    }

    func pullToRefresh() {
        searchParameters.removeValueForKey("pageToken")
        searchItems(parameters: searchParameters)
        refreshControll.endRefreshing()
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
        logger.debug("indexPath.row: \(indexPath.row), items.count: \(items.count)")
        if indexPath.row < items.count {
            return 100
        } else {
            return 50
        }
    }
}

extension ItemsViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if searchBar.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).isEmpty {
            return
        }
        if searchParameters["q"] == searchBar.text {
            return
        }
        items = []
        tableView.reloadData()
        searchItems(parameters: ["q": searchBar.text])
    }
    
}