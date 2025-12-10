//
//  HistorialMovimientosViewController.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class HistorialMovimientosViewController: UIViewController {
    
    // MARK: - Properties
    
    private let producto: Producto
    private var movimientos: [MovimientoStock] = []
    
    // MARK: - UI Components
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let productoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stockActualLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .systemGroupedBackground
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(MovimientoCell.self, forCellReuseIdentifier: MovimientoCell.identifier)
        return tv
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No hay movimientos registrados"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    init(producto: Producto) {
        self.producto = producto
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Historial de Movimientos"
        
        view.addSubview(headerView)
        headerView.addSubview(productoLabel)
        headerView.addSubview(stockActualLabel)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            productoLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            productoLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            productoLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            stockActualLabel.topAnchor.constraint(equalTo: productoLabel.bottomAnchor, constant: 2),
            stockActualLabel.leadingAnchor.constraint(equalTo: productoLabel.leadingAnchor),
            
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func loadData() {
        productoLabel.text = producto.descripcion
        stockActualLabel.text = "Stock actual: \(producto.stockFormateado)"
        
        movimientos = producto.stock?.movimientos.sorted { $0.fecha > $1.fecha } ?? []
        
        tableView.reloadData()
        emptyStateLabel.isHidden = !movimientos.isEmpty
        tableView.isHidden = movimientos.isEmpty
    }
}

// MARK: - UITableViewDataSource

extension HistorialMovimientosViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movimientos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovimientoCell.identifier, for: indexPath) as? MovimientoCell else {
            return UITableViewCell()
        }
        
        let movimiento = movimientos[indexPath.row]
        cell.configure(with: movimiento)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HistorialMovimientosViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
