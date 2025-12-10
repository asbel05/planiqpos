//
//  VentaViewController.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class VentaViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = VentaViewModel()
    
    // MARK: - UI Components
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Buscar producto por código o nombre"
        sb.searchBarStyle = .minimal
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    private let productosTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .systemGroupedBackground
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(ProductoBusquedaCell.self, forCellReuseIdentifier: ProductoBusquedaCell.identifier)
        return tv
    }()
    
    private let carritoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let carritoHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let carritoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "🛒 Carrito"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let itemsCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0 items"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let limpiarButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Limpiar", for: .normal)
        btn.setTitleColor(.systemRed, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let carritoTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .systemBackground
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(CarritoItemCell.self, forCellReuseIdentifier: CarritoItemCell.identifier)
        return tv
    }()
    
    private let totalesContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let subtotalLabel: UILabel = {
        let label = UILabel()
        label.text = "Subtotal: S/ 0.00"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let igvLabel: UILabel = {
        let label = UILabel()
        label.text = "IGV (18%): S/ 0.00"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.text = "S/ 0.00"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let clienteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("👤 Cliente general", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13)
        btn.contentHorizontalAlignment = .left
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let cobrarButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("COBRAR", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.backgroundColor = .systemGreen
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // Constraint para animar carrito
    private var carritoHeightConstraint: NSLayoutConstraint!
    private var carritoExpandido = true
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        viewModel.fetchProductos()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Punto de Venta"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "clock.arrow.circlepath"),
            style: .plain,
            target: self,
            action: #selector(historialTapped)
        )
        
        view.addSubview(searchBar)
        view.addSubview(productosTableView)
        view.addSubview(carritoContainerView)
        
        carritoContainerView.addSubview(carritoHeaderView)
        carritoHeaderView.addSubview(carritoTitleLabel)
        carritoHeaderView.addSubview(itemsCountLabel)
        carritoHeaderView.addSubview(limpiarButton)
        
        carritoContainerView.addSubview(carritoTableView)
        carritoContainerView.addSubview(totalesContainerView)
        
        totalesContainerView.addSubview(subtotalLabel)
        totalesContainerView.addSubview(igvLabel)
        totalesContainerView.addSubview(totalLabel)
        totalesContainerView.addSubview(clienteButton)
        
        carritoContainerView.addSubview(cobrarButton)
        
        carritoHeightConstraint = carritoContainerView.heightAnchor.constraint(equalToConstant: 340)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            productosTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            productosTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productosTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            productosTableView.bottomAnchor.constraint(equalTo: carritoContainerView.topAnchor),
            
            carritoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            carritoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            carritoContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            carritoHeightConstraint,
            
            carritoHeaderView.topAnchor.constraint(equalTo: carritoContainerView.topAnchor),
            carritoHeaderView.leadingAnchor.constraint(equalTo: carritoContainerView.leadingAnchor),
            carritoHeaderView.trailingAnchor.constraint(equalTo: carritoContainerView.trailingAnchor),
            carritoHeaderView.heightAnchor.constraint(equalToConstant: 44),
            
            carritoTitleLabel.centerYAnchor.constraint(equalTo: carritoHeaderView.centerYAnchor),
            carritoTitleLabel.leadingAnchor.constraint(equalTo: carritoHeaderView.leadingAnchor, constant: 16),
            
            itemsCountLabel.centerYAnchor.constraint(equalTo: carritoHeaderView.centerYAnchor),
            itemsCountLabel.leadingAnchor.constraint(equalTo: carritoTitleLabel.trailingAnchor, constant: 8),
            
            limpiarButton.centerYAnchor.constraint(equalTo: carritoHeaderView.centerYAnchor),
            limpiarButton.trailingAnchor.constraint(equalTo: carritoHeaderView.trailingAnchor, constant: -16),
            
            carritoTableView.topAnchor.constraint(equalTo: carritoHeaderView.bottomAnchor),
            carritoTableView.leadingAnchor.constraint(equalTo: carritoContainerView.leadingAnchor),
            carritoTableView.trailingAnchor.constraint(equalTo: carritoContainerView.trailingAnchor),
            carritoTableView.heightAnchor.constraint(equalToConstant: 120),
            
            totalesContainerView.topAnchor.constraint(equalTo: carritoTableView.bottomAnchor, constant: 8),
            totalesContainerView.leadingAnchor.constraint(equalTo: carritoContainerView.leadingAnchor, constant: 12),
            totalesContainerView.trailingAnchor.constraint(equalTo: carritoContainerView.trailingAnchor, constant: -12),
            totalesContainerView.heightAnchor.constraint(equalToConstant: 80),
            
            subtotalLabel.topAnchor.constraint(equalTo: totalesContainerView.topAnchor, constant: 10),
            subtotalLabel.leadingAnchor.constraint(equalTo: totalesContainerView.leadingAnchor, constant: 12),
            
            igvLabel.topAnchor.constraint(equalTo: subtotalLabel.bottomAnchor, constant: 2),
            igvLabel.leadingAnchor.constraint(equalTo: subtotalLabel.leadingAnchor),
            
            clienteButton.topAnchor.constraint(equalTo: igvLabel.bottomAnchor, constant: 4),
            clienteButton.leadingAnchor.constraint(equalTo: subtotalLabel.leadingAnchor),
            
            totalLabel.centerYAnchor.constraint(equalTo: totalesContainerView.centerYAnchor),
            totalLabel.trailingAnchor.constraint(equalTo: totalesContainerView.trailingAnchor, constant: -12),
            
            cobrarButton.topAnchor.constraint(equalTo: totalesContainerView.bottomAnchor, constant: 12),
            cobrarButton.leadingAnchor.constraint(equalTo: carritoContainerView.leadingAnchor, constant: 12),
            cobrarButton.trailingAnchor.constraint(equalTo: carritoContainerView.trailingAnchor, constant: -12),
            cobrarButton.heightAnchor.constraint(equalToConstant: 54),
            cobrarButton.bottomAnchor.constraint(lessThanOrEqualTo: carritoContainerView.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
        
        productosTableView.delegate = self
        productosTableView.dataSource = self
        carritoTableView.delegate = self
        carritoTableView.dataSource = self
        searchBar.delegate = self
        
        limpiarButton.addTarget(self, action: #selector(limpiarTapped), for: .touchUpInside)
        clienteButton.addTarget(self, action: #selector(clienteTapped), for: .touchUpInside)
        cobrarButton.addTarget(self, action: #selector(cobrarTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.onProductosUpdated = { [weak self] in
            self?.productosTableView.reloadData()
        }
        
        viewModel.onCarritoUpdated = { [weak self] in
            self?.carritoTableView.reloadData()
            self?.updateTotales()
        }
        
        viewModel.onError = { [weak self] message in
            self?.showError(message: message)
        }
        
        viewModel.onSuccess = { [weak self] message in
            self?.showToast(message: message)
        }
        
        viewModel.onVentaCompletada = { [weak self] pedido in
            self?.showComprobante(pedido: pedido)
        }
    }
    
    private func updateTotales() {
        itemsCountLabel.text = "\(viewModel.cantidadItems) items"
        subtotalLabel.text = "Subtotal: \(viewModel.subtotalFormateado)"
        igvLabel.text = "IGV (18%): \(viewModel.igvFormateado)"
        totalLabel.text = viewModel.totalFormateado
        
        cobrarButton.isEnabled = !viewModel.carritoVacio
        cobrarButton.alpha = viewModel.carritoVacio ? 0.5 : 1.0
        
        if let cliente = viewModel.clienteSeleccionado {
            clienteButton.setTitle("👤 \(cliente.nombreCompleto)", for: .normal)
        } else {
            clienteButton.setTitle("👤 Cliente general", for: .normal)
        }
    }
    
    // MARK: - Actions
    
    @objc private func historialTapped() {
        let historialVC = HistorialPedidosViewController()
        navigationController?.pushViewController(historialVC, animated: true)
    }
    
    @objc private func limpiarTapped() {
        guard !viewModel.carritoVacio else { return }
        
        let alert = UIAlertController(
            title: "Limpiar Carrito",
            message: "¿Deseas eliminar todos los productos?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Limpiar", style: .destructive) { [weak self] _ in
            self?.viewModel.limpiarCarrito()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func clienteTapped() {
        let clientesVC = ClientesViewController(modoSeleccion: true)
        clientesVC.onClienteSeleccionado = { [weak self] cliente in
            self?.viewModel.clienteSeleccionado = cliente
            self?.updateTotales()
        }
        navigationController?.pushViewController(clientesVC, animated: true)
    }
    
    @objc private func cobrarTapped() {
        guard !viewModel.carritoVacio else { return }
        
        let pagoVC = PagoViewController(total: viewModel.totalCarrito, viewModel: viewModel)
        pagoVC.modalPresentationStyle = .pageSheet
        if let sheet = pagoVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        present(pagoVC, animated: true)
    }
    
    private func showComprobante(pedido: Pedido) {
        let alert = UIAlertController(
            title: "✅ Venta Completada",
            message: "Pedido: \(pedido.numeroPedido)\nTotal: \(pedido.totalFormateado)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Helpers
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
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
            toastLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            toastLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 150),
            toastLabel.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.0, options: [], animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension VentaViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == productosTableView {
            return viewModel.productosFiltrados.count
        } else {
            return viewModel.carrito.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == productosTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductoBusquedaCell.identifier, for: indexPath) as? ProductoBusquedaCell else {
                return UITableViewCell()
            }
            
            let producto = viewModel.productosFiltrados[indexPath.row]
            cell.configure(with: producto)
            cell.onAgregarTapped = { [weak self] in
                self?.viewModel.agregarAlCarrito(producto)
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CarritoItemCell.identifier, for: indexPath) as? CarritoItemCell else {
                return UITableViewCell()
            }
            
            let item = viewModel.carrito[indexPath.row]
            cell.configure(with: item)
            cell.onIncrementar = { [weak self] in
                self?.viewModel.incrementarCantidad(itemId: item.id)
            }
            cell.onDecrementar = { [weak self] in
                self?.viewModel.decrementarCantidad(itemId: item.id)
            }
            cell.onEliminar = { [weak self] in
                self?.viewModel.eliminarDelCarrito(itemId: item.id)
            }
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension VentaViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == productosTableView {
            return 70
        } else {
            return 90
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == productosTableView {
            let producto = viewModel.productosFiltrados[indexPath.row]
            viewModel.agregarAlCarrito(producto)
        }
    }
}

// MARK: - UISearchBarDelegate

extension VentaViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.setBusqueda(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
