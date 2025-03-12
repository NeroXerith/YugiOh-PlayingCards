//
//  ViewController.swift
//  YugiOh-PlayingCards
//
//  Created by Biene Bryle Sanico on 3/11/25.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    private var apiService = YgorprodeckService()
    private var cards = [Card]()
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllCards()
    }

    func fetchAllCards() {
        apiService.fetchAllCards{ results in
            DispatchQueue.main.async {
                switch results {
                case .success(_):
                    print("cards")
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
                
            }
        }
    }
}

