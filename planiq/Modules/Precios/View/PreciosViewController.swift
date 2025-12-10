//
//  PreciosViewController.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class PreciosViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = PreciosViewModel()
    private var producto: Producto?
    private var showingAllProducts: Bool
    
    // MARK: - UI Components
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Buscar producto"
        sb.searchBarStyle = .minimal
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .systemGroupedBackground
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(PrecioCell.self, forCellReuseIdentifier: PrecioCell.identifier)
        return tv
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No hay precios\nToca + para agregar uno"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    init(producto: Producto? = nil) {
        self.producto = producto
        self.showingAllProducts = (producto == nil)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        viewModel.fetchProductosConPrecios()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = showingAllProducts ? "Precios" : "Precios - \(producto?.descripcion ?? "")"
        
        if showingAllProducts {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(addTapped)
            )
            
            view.addSubview(searchBar)
            searchBar.delegate = self
            
            NSLayoutConstraint.activate([
                searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
                searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
            ])
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(addPrecioTapped)
            )
        }
        
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        let topAnchor = showingAllProducts ? searchBar.bottomAnchor : view.safeAreaLayoutGuide.topAnchor
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor, constant: showingAllProducts ? 0 : 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupBindings() {
        viewModel.onPreciosUpdated = { [weak self] in
            self?.tableView.reloadData()
            self?.updateEmptyState()
        }
        
        viewModel.onError = { [weak self] message in
            self?.showAlert(title: "Error", message: message)
        }
        
        viewModel.onSuccess = { [weak self] message in
            self?.showToast(message: message)
        }
    }
    
    private func updateEmptyState() {
        let isEmpty: Bool
        if showingAllProducts {
            isEmpty = viewModel.productosFiltrados.isEmpty
        } else {
            isEmpty = producto?.precios.isEmpty ?? true
        }
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    // MARK: - Data Source Helpers
    
    private func getProductos() -> [Producto] {
        if showingAllProducts {
            return viewModel.productosFiltrados
        } else if let producto = producto {
            return [producto]
        }
        return []
    }
    
    private func getPrecios(for producto: Producto) -> [Precio] {
        return producto.precios.sorted { $0.esActivo && !$1.esActivo }
    }
    
    // MARK: - Actions
    
    @objc private func addTapped() {
        let alert = UIAlertController(title: "Seleccionar Producto", message: nil, preferredStyle: .actionSheet)
        
        for producto in viewModel.fetchProductos() {
            alert.addAction(UIAlertAction(title: "\(producto.codigo) - \(producto.descripcion)", style: .default) { [weak self] _ in
                self?.navigateToPrecioForm(producto: producto, precio: nil)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func addPrecioTapped() {
        guard let producto = producto else { return }
        navigateToPrecioForm(producto: producto, precio: nil)
    }
    
    private func navigateToPrecioForm(producto: Producto, precio: Precio?) {
        let formVC = PrecioFormViewController(producto: producto, precio: precio, viewModel: viewModel)
        navigationController?.pushViewController(formVC, animated: true)
    }
    
    // MARK: - Helpers
    
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

extension PreciosViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return getProductos().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let productos = getProductos()
        guard section < productos.count else { return 0 }
        return getPrecios(for: productos[section]).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PrecioCell.identifier, for: indexPath) as? PrecioCell else {
            return UITableViewCell()
        }
        
        let productos = getProductos()
        guard indexPath.section < productos.count else { return cell }
        
        let producto = productos[indexPath.section]
        let precios = getPrecios(for: producto)
        guard indexPath.row < precios.count else { return cell }
        
        cell.configure(with: precios[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let productos = getProductos()
        guard section < productos.count else { return nil }
        
        let producto = productos[section]
        
        let headerView = UIView()
        headerView.backgroundColor = .systemGroupedBackground
        
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        if let imageData = producto.imagen, let image = UIImage(data: imageData) {
            imageView.image = image
        } else {
            imageView.image = UIImage(systemName: "cube.box.fill")
            imageView.tintColor = .systemGray3
            imageView.contentMode = .scaleAspectFit
        }
        
        let codigoLabel = UILabel()
        codigoLabel.text = producto.codigo
        codigoLabel.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        codigoLabel.textColor = .systemBlue
        codigoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let nombreLabel = UILabel()
        nombreLabel.text = producto.descripcion
        nombreLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nombreLabel.textColor = .label
        nombreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let preciosCountLabel = UILabel()
        preciosCountLabel.text = "\(producto.precios.count) precio(s)"
        preciosCountLabel.font = .systemFont(ofSize: 12)
        preciosCountLabel.textColor = .secondaryLabel
        preciosCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(codigoLabel)
        containerView.addSubview(nombreLabel)
        containerView.addSubview(preciosCountLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -4),
            
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 40),
            imageView.heightAnchor.constraint(equalToConstant: 40),
            
            codigoLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            codigoLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            
            nombreLabel.topAnchor.constraint(equalTo: codigoLabel.bottomAnchor, constant: 2),
            nombreLabel.leadingAnchor.constraint(equalTo: codigoLabel.leadingAnchor),
            nombreLabel.trailingAnchor.constraint(equalTo: preciosCountLabel.leadingAnchor, constant: -8),
            
            preciosCountLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            preciosCountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
}

// MARK: - UITableViewDelegate

extension PreciosViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productos = getProductos()
        guard indexPath.section < productos.count else { return }
        
        let producto = productos[indexPath.section]
        let precios = getPrecios(for: producto)
        guard indexPath.row < precios.count else { return }
        
        let precio = precios[indexPath.row]
        navigateToPrecioForm(producto: producto, precio: precio)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let productos = getProductos()
        guard indexPath.section < productos.count else { return nil }
        
        let producto = productos[indexPath.section]
        let precios = getPrecios(for: producto)
        guard indexPath.row < precios.count else { return nil }
        
        let precio = precios[indexPath.row]
        
        var actions: [UIContextualAction] = []
        
        // Activar (solo si no está activo)
        if !precio.esActivo {
            let activarAction = UIContextualAction(style: .normal, title: "Activar") { [weak self] _, _, completion in
                self?.viewModel.activarPrecio(precio)
                completion(true)
            }
            activarAction.backgroundColor = .systemGreen
            actions.append(activarAction)
        }
        
        // Eliminar
        let deleteAction = UIContextualAction(style: .destructive, title: "Eliminar") { [weak self] _, _, completion in
            let alert = UIAlertController(
                title: "Eliminar Precio",
                message: "¿Estás seguro de eliminar este precio?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel) { _ in
                completion(false)
            })
            
            alert.addAction(UIAlertAction(title: "Eliminar", style: .destructive) { _ in
                _ = self?.viewModel.deletePrecio(precio)
                completion(true)
            })
            
            self?.present(alert, animated: true)
        }
        actions.append(deleteAction)
        
        return UISwipeActionsConfiguration(actions: actions)
    }
}

// MARK: - UISearchBarDelegate

extension PreciosViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.setBusqueda(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
