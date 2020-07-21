//
//  PlaceListViewController.swift
//  MoreThanBD
//
//  Created by Sai Akhil Pulikam on 7/20/20.
//  Copyright © 2020 Xiaowen Ma. All rights reserved.
//

import UIKit

class PlaceListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: PlaceTableViewCell.NIB_NAME, bundle: nil), forCellReuseIdentifier: Constants.placeCellId)
    }
}

extension PlaceListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.placeCellId, for: indexPath) as! PlaceTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}


extension PlaceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(identifier: "DetailedVC") as! DetailedVC
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension PlaceListViewController {
    struct Constants {
        static let placeCellId = "placeCellId"
    }
}
