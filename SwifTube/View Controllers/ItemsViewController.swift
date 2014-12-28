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

    var searcher = SwifTube.Client()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configure(tableView)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = self.navigationController? {
            //navigationController.hidesBarsOnSwipe = true
            //navigationController.setNavigationBarHidden(true, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure(tableView: UITableView) {
        tableView.delegate = self
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ItemsViewController: UITableViewDelegate {
}