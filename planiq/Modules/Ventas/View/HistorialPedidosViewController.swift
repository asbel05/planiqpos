//
//  HistorialPedidosViewController.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class HistorialPedidosViewController: UIViewController {
    
    private let viewModel = HistorialPedidosViewModel()
    
    private let segmentedControl: UISegmentedControl = {
        let items = FiltroPeriodo.allCases.map { $0.titulo }
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 1
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .systemGroupedBackground
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(PedidoCell.self, forCellReuseIdentifier: PedidoCell.identifier)
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.setFiltro(.hoy)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchPedidos()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Historial de Ventas"
        
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    private func setupBindings() {
        viewModel.onPedidosUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @objc private func segmentChanged() {
        guard let filtro = FiltroPeriodo(rawValue: segmentedControl.selectedSegmentIndex) else { return }
        viewModel.setFiltro(filtro)
    }
}

extension HistorialPedidosViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.pedidosFiltrados.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PedidoCell.identifier, for: indexPath) as? PedidoCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.pedidosFiltrados[indexPath.row])
        return cell
    }
}

extension HistorialPedidosViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 100 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pedido = viewModel.pedidosFiltrados[indexPath.row]
        let detalleVC = DetallePedidoViewController(pedido: pedido)
        navigationController?.pushViewController(detalleVC, animated: true)
    }
}
