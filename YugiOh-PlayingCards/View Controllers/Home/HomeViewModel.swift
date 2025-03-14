//
//  Untitled.swift
//  YugiOh-PlayingCards
//
//  Created by Biene Bryle Sanico on 3/12/25.
//
import Foundation

enum Types: Int, CaseIterable {
    case all
    case monsters
    case spell
    case trap
    
    var name: String {
        switch self {
        case .all: return "All"
        case .monsters: return "Monsters"
        case .spell: return "Spell"
        case .trap: return "Trap"
        }
    }
}

final class HomeViewModel {
    weak var delegate: RequestDelegate?
    private var state: ViewState {
        didSet {
            self.delegate?.didUpdate(with: state)
        }
    }
    private var cardFetcher = YgorprodeckService()
    private var cards: [Card] = []
    private var filteredCards: [Card] = []
    private var selectedType: Types = .all {
        didSet {
            self.filterData()
        }
    }
    
    init() {
        self.state = .idle
    }
}

// MARK: - Data Source
extension HomeViewModel {
    var numberOfItems: Int {
        filteredCards.count
    }
    
    func getInfo(for indexPath: IndexPath) -> (name: String, type: String, desc: String, imageURL: String?) {
        let card = filteredCards[indexPath.row]
        return (name: card.name, type: card.type, desc: card.desc, imageURL: card.cardImages.first?.imageURL)
    }
}

// MARK: - Service
extension HomeViewModel {
    func loadData() {
        self.state = .loading
        cardFetcher.fetchAllCards { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cards):
                    self?.cards = cards
                    self?.filteredCards = cards
                    self?.state = .success
                case .failure(let error):
                    self?.cards = []
                    self?.filteredCards = []
                    self?.state = .error(error)
                }
            }
        }
    }
    
    func filterByType(type: Types) {
        self.selectedType = type
    }
    
    func selectedTypeName() -> String {
        self.selectedType.name
    }
}

private extension HomeViewModel {
    func filterData() {
        guard selectedType != .all else {
            self.filteredCards = cards
            self.state = .success
            return
        }
        
        guard selectedType != .monsters else {
            self.filteredCards = self.cards.filter {
                !$0.type.lowercased().contains(Types.spell.name.lowercased()) && !$0.type.lowercased().contains(Types.trap.name.lowercased()) }
            self.state = .success
            return
            
        }
        self.filteredCards = self.cards.filter {
            $0.type.lowercased().contains(self.selectedType.name.lowercased())
        }
            self.state = .success
    }
}
