//
//  ComplexWorkViewController.swift
//  ККВФ
//
//  Created by Акифьев Максим  on 30.06.2021.
//

import UIKit

class ComplexWorkViewController: UIViewController {

    var array = ["1", "2"]
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.estimatedRowHeight = 44.0
//        tableView.rowHeight = UITableView.automaticDimension
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//        self.navigationController?.navigationBar.topItem?.title = "Работа ЦОДД-ЦАФАП"
    }

}
