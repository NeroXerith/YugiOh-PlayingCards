//
//  Untitled.swift
//  YugiOh-PlayingCards
//
//  Created by Biene Bryle Sanico on 3/12/25.
//
import Foundation
import Combine

enum Types: String, CaseIterable {
    case all = "All"
    case monsters = "Monster"
    case spell = "Spell"
    case trap = "Trap"
    
    var name: String {
        self.rawValue
    }
    
}

final class HomeViewModel {
//    weak var delegate: RequestDelegate?
//    private var state: ViewState {
//        didSet {
//            self.delegate?.didUpdate(with: state)
//        }
//    }
    private var cardFetcher = YgorprodeckService()
    private var cancellables = Set<AnyCancellable>()
//    private var cards: [Card] = []
//    private var filteredCards: [Card] = []
//    private var selectedType: Types = .all {
//        didSet {
//            self.filterData()
//        }
//    }
//    
//    init() {
//        self.state = .idle
//    }
    
    @Published private(set) var filteredCards: [Card] = []
    @Published private(set) var selectedType: Types = .all
    @Published private(set) var state: ViewState = .idle
    @Published private(set) var items: [Card] = []
    
    init(){
        self.state = .idle
        setupFiltering()
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
        state = .loading
        
        cardFetcher.fetchAllCards()
            .receive(on: DispatchQueue.main) // Main thread UI Updates
            .sink(receiveCompletion: { [weak self] response in
                guard let self else { return }
                switch response {
                case .finished:
                    self.state = .success
                case .failure(let error):
                    self.state = .error(error)
                }
            }, receiveValue: { [weak self] cards in
                self?.items = cards
                self?.filterData()
            })
            .store(in: &cancellables)
    }
    
    func setupFiltering() {
        $selectedType
            .sink { [weak self] _ in self?.filterData() }
            .store(in: &cancellables)
    }
}

private extension HomeViewModel {
    func filterData() {
        if selectedType == .all {
            filteredCards = items
        } else {
            filteredCards = items.filter { $0.type == selectedType.rawValue }
        }
    }
}
