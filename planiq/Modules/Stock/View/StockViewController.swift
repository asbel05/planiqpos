//
//  StockViewController.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class StockViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = StockViewModel()
    
    // MARK: - UI Components
    
    private let statsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private lazy var totalCard = createStatCard(title: "Total Productos", color: .systemBlue)
    private lazy var bajoCard = createStatCard(title: "Stock Bajo", color: .systemOrange)
    private lazy var sinStockCard = createStatCard(title: "Sin Stock", color: .systemRed)
    
    private let segmentedControl: UISegmentedControl = {
        let items = FiltroStock.allCases.map { $0.titulo }
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Buscar producto"
        sb.searchBarStyle = .minimal
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .systemGroupedBackground
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(StockCell.self, forCellReuseIdentifier: StockCell.identifier)
        return tv
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No hay productos"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        viewModel.fetchProductosConStock()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Inventario"
        
        view.addSubview(statsStackView)
        statsStackView.addArrangedSubview(totalCard.view)
        statsStackView.addArrangedSubview(bajoCard.view)
        statsStackView.addArrangedSubview(sinStockCard.view)
        
        view.addSubview(segmentedControl)
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            statsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            statsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statsStackView.heightAnchor.constraint(equalToConstant: 80),
            
            segmentedControl.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            searchBar.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        // Tap en cards
        totalCard.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(totalCardTapped)))
        bajoCard.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bajoCardTapped)))
        sinStockCard.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sinStockCardTapped)))
    }
    
    private func setupBindings() {
        viewModel.onStockUpdated = { [weak self] in
            self?.tableView.reloadData()
            self?.updateStats()
            self?.updateEmptyState()
        }
        
        viewModel.onError = { [weak self] message in
            self?.showAlert(title: "Error", message: message)
        }
        
        viewModel.onSuccess = { [weak self] message in
            self?.showToast(message: message)
        }
    }
    
    private func updateStats() {
        totalCard.valueLabel.text = "\(viewModel.totalProductos)"
        bajoCard.valueLabel.text = "\(viewModel.totalStockBajo)"
        sinStockCard.valueLabel.text = "\(viewModel.totalSinStock)"
    }
    
    private func updateEmptyState() {
        let isEmpty = viewModel.productosFiltrados.isEmpty
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    // MARK: - Actions
    
    @objc private func segmentChanged() {
        guard let filtro = FiltroStock(rawValue: segmentedControl.selectedSegmentIndex) else { return }
        viewModel.setFiltro(filtro)
    }
    
    @objc private func totalCardTapped() {
        segmentedControl.selectedSegmentIndex = 0
        viewModel.setFiltro(.todos)
    }
    
    @objc private func bajoCardTapped() {
        segmentedControl.selectedSegmentIndex = 1
        viewModel.setFiltro(.stockBajo)
    }
    
    @objc private func sinStockCardTapped() {
        segmentedControl.selectedSegmentIndex = 2
        viewModel.setFiltro(.sinStock)
    }
    
    // MARK: - Helpers
    
    private func createStatCard(title: String, color: UIColor) -> (view: UIView, valueLabel: UILabel) {
        let card = UIView()
        card.backgroundColor = color
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        card.isUserInteractionEnabled = true
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 11, weight: .medium)
        titleLabel.textColor = .white.withAlphaComponent(0.8)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = "0"
        valueLabel.font = .systemFont(ofSize: 28, weight: .bold)
        valueLabel.textColor = .white
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(titleLabel)
        card.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12)
        ])
        
        return (card, valueLabel)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toastLabel)
        
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            toastLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 150),
            toastLabel.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: [], animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension StockViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.productosFiltrados.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StockCell.identifier, for: indexPath) as? StockCell else {
            return UITableViewCell()
        }
        
        let producto = viewModel.productosFiltrados[indexPath.row]
        cell.configure(with: producto)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension StockViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let producto = viewModel.productosFiltrados[indexPath.row]
        showActionSheet(for: producto)
    }
    
    private func showActionSheet(for producto: Producto) {
        let alert = UIAlertController(
            title: producto.descripcion,
            message: "Stock actual: \(producto.stockFormateado)",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Ajustar Stock", style: .default) { [weak self] _ in
            self?.showAjusteStock(producto: producto)
        })
        
        alert.addAction(UIAlertAction(title: "Ver Historial", style: .default) { [weak self] _ in
            let historialVC = HistorialMovimientosViewController(producto: producto)
            self?.navigationController?.pushViewController(historialVC, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showAjusteStock(producto: Producto) {
        let ajusteVC = AjusteStockViewController(producto: producto, viewModel: viewModel)
        ajusteVC.modalPresentationStyle = .pageSheet
        if let sheet = ajusteVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        present(ajusteVC, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension StockViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.setBusqueda(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
