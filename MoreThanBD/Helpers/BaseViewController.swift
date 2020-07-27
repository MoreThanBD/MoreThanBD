//
//  BaseViewController.swift
//  MoreThanBD
//
//  Created by Sai Akhil Pulikam on 7/27/20.
//  Copyright © 2020 Xiaowen Ma. All rights reserved.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
