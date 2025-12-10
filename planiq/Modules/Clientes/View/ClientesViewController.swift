//
//  ClientesViewController.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class ClientesViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = ClientesViewModel()
    var onClienteSeleccionado: ((Cliente) -> Void)?
    private var modoSeleccion: Bool
    
    // MARK: - UI Components
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Buscar por nombre o documento"
        sb.searchBarStyle = .minimal
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .systemGroupedBackground
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(ClienteCell.self, forCellReuseIdentifier: ClienteCell.identifier)
        return tv
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No hay clientes\nToca + para agregar uno"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    init(modoSeleccion: Bool = false) {
        self.modoSeleccion = modoSeleccion
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
        viewModel.fetchClientes()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = modoSeleccion ? "Seleccionar Cliente" : "Clientes"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTapped)
        )
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    private func setupBindings() {
        viewModel.onClientesUpdated = { [weak self] in
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
        let isEmpty = viewModel.clientesFiltrados.isEmpty
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    // MARK: - Actions
    
    @objc private func addTapped() {
        showClienteForm(cliente: nil)
    }
    
    private func showClienteForm(cliente: Cliente?) {
        let isEditing = cliente != nil
        let alert = UIAlertController(
            title: isEditing ? "Editar Cliente" : "Nuevo Cliente",
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addTextField { tf in
            tf.placeholder = "Nombres *"
            tf.text = cliente?.nombres
            tf.autocapitalizationType = .words
        }
        
        alert.addTextField { tf in
            tf.placeholder = "Apellidos"
            tf.text = cliente?.apellidos
            tf.autocapitalizationType = .words
        }
        
        alert.addTextField { tf in
            tf.placeholder = "Número de documento *"
            tf.text = cliente?.numeroDocumento
            tf.keyboardType = .numberPad
        }
        
        alert.addTextField { tf in
            tf.placeholder = "Teléfono"
            tf.text = cliente?.telefono
            tf.keyboardType = .phonePad
        }
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Guardar", style: .default) { [weak self] _ in
            let nombres = alert.textFields?[0].text ?? ""
            let apellidos = alert.textFields?[1].text
            let documento = alert.textFields?[2].text ?? ""
            let telefono = alert.textFields?[3].text
            
            if let cliente = cliente {
                self?.viewModel.updateCliente(
                    cliente,
                    nombres: nombres,
                    apellidos: apellidos,
                    tipoDocumento: cliente.tipoDocumento,
                    numeroDocumento: documento,
                    telefono: telefono,
                    email: cliente.email,
                    direccion: cliente.direccion
                )
            } else {
                self?.viewModel.addCliente(
                    nombres: nombres,
                    apellidos: apellidos,
                    tipoDocumento: .dni,
                    numeroDocumento: documento,
                    telefono: telefono,
                    email: nil,
                    direccion: nil
                )
            }
        })
        
        present(alert, animated: true)
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

extension ClientesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.clientesFiltrados.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ClienteCell.identifier, for: indexPath) as? ClienteCell else {
            return UITableViewCell()
        }
        
        let cliente = viewModel.clientesFiltrados[indexPath.row]
        cell.configure(with: cliente)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ClientesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cliente = viewModel.clientesFiltrados[indexPath.row]
        
        if modoSeleccion {
            onClienteSeleccionado?(cliente)
            navigationController?.popViewController(animated: true)
        } else {
            showClienteForm(cliente: cliente)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !modoSeleccion else { return nil }
        
        let cliente = viewModel.clientesFiltrados[indexPath.row]
        
        let toggleTitle = cliente.estado ? "Desactivar" : "Activar"
        let toggleColor: UIColor = cliente.estado ? .systemOrange : .systemGreen
        
        let toggleAction = UIContextualAction(style: .normal, title: toggleTitle) { [weak self] _, _, completion in
            self?.viewModel.toggleEstado(cliente)
            completion(true)
        }
        toggleAction.backgroundColor = toggleColor
        
        return UISwipeActionsConfiguration(actions: [toggleAction])
    }
}

// MARK: - UISearchBarDelegate

extension ClientesViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.setBusqueda(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
