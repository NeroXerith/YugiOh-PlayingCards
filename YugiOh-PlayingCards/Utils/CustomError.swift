//
//  CustomError.swift
//  YugiOh-PlayingCards
//
//  Created by Biene Bryle Sanico on 3/11/25.
//

import Foundation

enum CustomError {
    case noConnection, noData
}

extension CustomError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return NSLocalizedString("No connection found", comment: "")
        case .noData:
            return NSLocalizedString("No data found", comment: "")
        }
    }
}
