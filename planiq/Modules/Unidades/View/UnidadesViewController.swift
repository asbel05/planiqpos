//
//  UnidadesViewController.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class UnidadesViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = UnidadesViewModel()
    
    // MARK: - UI Components
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .systemGroupedBackground
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(UnidadCell.self, forCellReuseIdentifier: UnidadCell.identifier)
        return tv
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No hay unidades\nToca + para agregar una"
        label.numberOfLines = 2
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
        viewModel.fetchUnidades()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Unidades"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTapped)
        )
        
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
        viewModel.onUnidadesUpdated = { [weak self] in
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
        emptyStateLabel.isHidden = !viewModel.unidades.isEmpty
        tableView.isHidden = viewModel.unidades.isEmpty
    }
    
    // MARK: - Actions
    
    @objc private func addTapped() {
        showUnidadAlert(unidad: nil)
    }
    
    private func showUnidadAlert(unidad: Unidad?) {
        let isEditing = unidad != nil
        let alert = UIAlertController(
            title: isEditing ? "Editar Unidad" : "Nueva Unidad",
            message: "Ejemplo: Kilogramo (kg)",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Nombre (ej: Kilogramo)"
            textField.text = unidad?.nombre
            textField.autocapitalizationType = .words
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Abreviatura (ej: kg)"
            textField.text = unidad?.abreviatura
            textField.autocapitalizationType = .none
        }
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Guardar", style: .default) { [weak self] _ in
            guard let nombre = alert.textFields?[0].text,
                  let abreviatura = alert.textFields?[1].text else { return }
            
            if let unidad = unidad {
                self?.viewModel.updateUnidad(unidad, nombre: nombre, abreviatura: abreviatura)
            } else {
                self?.viewModel.addUnidad(nombre: nombre, abreviatura: abreviatura)
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

extension UnidadesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.unidades.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UnidadCell.identifier, for: indexPath) as? UnidadCell else {
            return UITableViewCell()
        }
        
        let unidad = viewModel.unidades[indexPath.row]
        cell.configure(with: unidad)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension UnidadesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let unidad = viewModel.unidades[indexPath.row]
        showUnidadAlert(unidad: unidad)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let unidad = viewModel.unidades[indexPath.row]
        
        let toggleTitle = unidad.estado ? "Desactivar" : "Activar"
        let toggleColor: UIColor = unidad.estado ? .systemOrange : .systemGreen
        
        let toggleAction = UIContextualAction(style: .normal, title: toggleTitle) { [weak self] _, _, completion in
            self?.viewModel.toggleEstado(unidad)
            completion(true)
        }
        toggleAction.backgroundColor = toggleColor
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Eliminar") { [weak self] _, _, completion in
            let alert = UIAlertController(
                title: "Eliminar Unidad",
                message: "¿Estás seguro de eliminar '\(unidad.nombre)'?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel) { _ in
                completion(false)
            })
            
            alert.addAction(UIAlertAction(title: "Eliminar", style: .destructive) { _ in
                _ = self?.viewModel.deleteUnidad(unidad)
                completion(true)
            })
            
            self?.present(alert, animated: true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, toggleAction])
    }
}
