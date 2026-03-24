//
//  ViewController.swift
//  Market
//
//  Created by Дмитриев Антон on 18.03.2026.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var btn_select_currency: UIButton!
    @IBAction func optionSelection(_ sender: UIAction) {
        print(sender.title)
        self.btn_select_currency.setTitle(sender.title, for: .normal)
    }

}

