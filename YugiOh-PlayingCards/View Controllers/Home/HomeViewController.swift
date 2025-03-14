//
//  HomeViewController.swift
//  YugiOh-PlayingCards
//
//  Created by Biene Bryle Sanico on 3/12/25.
//

import Foundation
import UIKit
import SnapKit
import Combine

class HomeViewController: UIViewController {
    
    private lazy var filterSegment: UISegmentedControl = {
        let segmented = UISegmentedControl(items: Types.allCases.map { $0.name })
        segmented.selectedSegmentIndex = 0
        return segmented
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(CardListCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        return tableView
    }()
    
    // UIActivityIndicatorView for loading
       private let loadingIndicator: UIActivityIndicatorView = {
           let indicator = UIActivityIndicatorView(style: .large)
           indicator.hidesWhenStopped = true
           return indicator
       }()

    private let viewModel: HomeViewModel
    @Published var cancellables = Set<AnyCancellable>()
    
    required init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.largeTitleDisplayMode = .always
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        configureLayout()
        setupBindings()
        viewModel.loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: UI Setup
private extension HomeViewController {
    func setupNavigation() {
        navigationItem.titleView = filterSegment
    }
    func configureLayout() {
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview() // Center the loading indicator
        }
    }
}

// MARK: Loading Indicator Methods
private extension HomeViewController {
    func startLoading() {
        loadingIndicator.startAnimating()
        tableView.isUserInteractionEnabled = false // Disable interactions while loading
    }

    func stopLoading() {
        loadingIndicator.stopAnimating()
        tableView.isUserInteractionEnabled = true // Re-enable interactions
    }
}

// MARK: Actions
private extension HomeViewController {
    func handleViewState(_ state: ViewState) {
        switch state {
        case .idle:
            break
        case .loading:
            self.startLoading()
        case .success:
            self.tableView.setContentOffset(.zero, animated: true)
            self.tableView.reloadData()
            self.stopLoading()
        case .error(let error):
            self.stopLoading()
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { [weak self] _ in
                self?.viewModel.loadData()
            }))
            self.present(alert, animated: true)

        }
    }
    
    // MARK: - Segmented Control Change Handler
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let selectedType = Types.allCases[sender.selectedSegmentIndex]
        print("Segment changed to: \(selectedType.rawValue)") // Debugging log
        viewModel.updateSelectedType(selectedType)
    }


    
    func setupBindings() {
        // Bind segmented control changes explicitly
        filterSegment.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)

        // Observe filteredCards and reload table view
        viewModel.$filteredCards
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cards in
                print("Filtered cards count: \(cards.count)") // Debug log
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        // Observe view state changes
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.handleViewState(state) }
            .store(in: &cancellables)
    }


}

// MARK: UITableViewDataSource & UITableViewDelegate
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CardListCell
        cell.configure(info: viewModel.getInfo(for: indexPath))
        return cell
    }
}
