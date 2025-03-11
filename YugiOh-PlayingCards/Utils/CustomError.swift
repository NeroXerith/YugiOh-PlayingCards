//
//  CustomError.swift
//  YugiOh-PlayingCards
//
//  Created by Biene Bryle Sanico on 3/11/25.
//

import Foundation

enum CustomError: Error {
    case noConnection, noData
}

extension CustomError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return "No internet connection"
        case .noData:
            return "No data available"
        }
    }
}
