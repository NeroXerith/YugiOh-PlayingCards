//
//  HomeViewController.swift
//  YugiOh-PlayingCards
//
//  Created by Biene Bryle Sanico on 3/12/25.
//

import Foundation
import UIKit
import SnapKit

class HomeViewController: UIViewController {
    
    private lazy var filterSegment: UISegmentedControl = {
        let segmented = UISegmentedControl(items: Types.allCases.map { $0.name })
        segmented.selectedSegmentIndex = 0
        segmented.addTarget(self, action: #selector(didSelectItem(_:)), for: .valueChanged)
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

    required init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil) // Fix: Corrected super.init() call
        self.viewModel.delegate = self
        navigationItem.largeTitleDisplayMode = .always
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        configureLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadData()
    }
}

// MARK: UI Setup
private extension HomeViewController {
    func setupNavigation() {
        navigationItem.titleView = filterSegment
    }
    func configureLayout() {
        view.addSubview(tableView)
        view.addSubview(loadingIndicator) // Make sure to add the loading indicator!

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
    @objc func didSelectItem(_ selector: UISegmentedControl) {
        self.viewModel.filterByType(type: Types(rawValue: selector.selectedSegmentIndex) ?? .all)
    }
}

// MARK: UITableViewDataSource & UITableViewDelegate
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CardListCell // Fix: Corrected dequeue method
        cell.configure(info: viewModel.getInfo(for: indexPath))
        return cell
    }
}

// MARK: RequestDelegate
extension HomeViewController: RequestDelegate {

    
    
    func didUpdate(with state: ViewState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
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
    }
}
