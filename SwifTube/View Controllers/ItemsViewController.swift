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

    //var searcher = (client: SwifTube.Client(), parameters: [String: String]())
    var searchParameters = [String: String]()
    var populatingItems = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configure(navigationItem: navigationItem)
        configure(tableView: tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure(#navigationItem: UINavigationItem) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }

    func configure(#tableView: UITableView) {
        tableView.delegate = self
    }

    func search() {
    }
    
    func updateSearchParameters(#token: SwifTube.PageToken!) {
        println("searchParameters: \(searchParameters)")
        if let token = token {
            searchParameters["pageToken"] = token.next
        }
    }

}

extension ItemsViewController: UITableViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8 {
            populateItems()
        }
    }

    func populateItems() {
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