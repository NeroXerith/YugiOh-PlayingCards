//
//  YgorprodeckService.swift
//  YugiOh-PlayingCards
//
//  Created by Biene Bryle Sanico on 3/11/25.
//

import Foundation
import Alamofire
import Combine

final class YgorprodeckService {
    
    private enum ApiURL {
        case main
        case db
        var baseURL: String {
            switch self {
                case .main: return "https://ygoprodeck.com"
                case .db : return "https://db.ygoprodeck.com/api/v7"
            }
        }
    }
    
    private enum Endpoint {
        case cardList
        case imageArchetype
        
        var path: String{
            switch self {
            case .cardList: return "/cardinfo.php"
            case .imageArchetype: return "/pics/icons/archetype.png"
            }
        }
        
        var url: String {
            switch self {
            case .cardList: return "\(ApiURL.db.baseURL)\(path)"
            default: return ":"
            }
        }
    }
    
    func fetchAllCards() -> AnyPublisher<[Card], Error> {
        let urlString = Endpoint.cardList.url
        debugPrint("🌐 Fetching from : \(urlString)")
        return AF.request(urlString)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .publishDecodable(type: CardResponse.self)
            .tryMap { response in
                guard let cards = response.value else { throw CustomError.noConnection }
                    debugPrint("✅ Successfully fetched \(cards.data.count) cards")
                return cards.data
                }
            .eraseToAnyPublisher()
    }
}


