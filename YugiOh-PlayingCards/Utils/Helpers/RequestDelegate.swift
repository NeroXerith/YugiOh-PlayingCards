//
//  RequestDelegate.swift
//  YugiOh-PlayingCards
//
//  Created by Biene Bryle Sanico on 3/12/25.
//

import Foundation

protocol RequestDelegate: AnyObject {
    func didUpdate(with state: ViewState)
}
