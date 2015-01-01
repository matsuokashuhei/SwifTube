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

    func setTokenToSearchParameters(#token: SwifTube.PageToken!) {
        if let token = token {
            searchParameters["pageToken"] = token.next.isEmpty ? "" : token.next
        }
    }

    func searchItemsCompletion(#items: [SwifTube.Item]!, token: SwifTube.PageToken!, error: NSError!) {
        if let items = items {
            /*
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                self.setTokenToSearchParameters(token: token)
                self.items = items
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
            */
            Async.background {
                self.setTokenToSearchParameters(token: token)
                self.items = items
            }.main {
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }
        }
    }

    func loadMoreItemsCompletion(#items: [SwifTube.Item]!, token: SwifTube.PageToken!, error: NSError!) {
        if let items = items {
            self.setTokenToSearchParameters(token: token)
            /*
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                for item in items {
                    self.items.append(item)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
            */
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
        // TODO: 無駄に検索しない。
        items = []
        tableView.reloadData()
        searchBar.resignFirstResponder()
        searchItems(parameters: ["q": searchBar.text])
    }
    
}