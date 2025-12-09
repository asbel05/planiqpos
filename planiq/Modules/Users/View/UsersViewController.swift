//
//  UsersViewController.swift
//  planiq
//
//  Created by Asbel on 8/12/25.
//

import UIKit

final class UsersViewController: UIViewController {
    
    private lazy var viewModel = UsersViewModel(modelContext: AppDelegate.sharedModelContainer.mainContext)
    
    // MARK: - UI
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        return tv
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No hay usuarios registrados"
        label.textColor = .gray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Usuarios"
        
        setupNavigation()
        setupUI()
        setupBindings()
        viewModel.loadUsers()
    }
    
    // MARK: - Setup
    
    private func setupNavigation() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addUserTapped))
        navigationItem.rightBarButtonItem = addButton
        
        let backButton = UIBarButtonItem()
        backButton.title = "Atrás"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupBindings() {
        viewModel.onUsersLoaded = { [weak self] in
            self?.tableView.reloadData()
            self?.emptyLabel.isHidden = !(self?.viewModel.users.isEmpty ?? true)
        }
        
        viewModel.onErrorMessage = { [weak self] msg in
            self?.showAlert(title: "Error", message: msg)
        }
        
        viewModel.onUserDeleted = { [weak self] in
            self?.viewModel.loadUsers()
        }
    }
    
    // MARK: - Actions
    
    @objc private func addUserTapped() {
        let addVC = AddUserViewController()
        addVC.onUserAdded = { [weak self] in
            self?.viewModel.loadUsers()
        }
        let navController = UINavigationController(rootViewController: addVC)
        present(navController, animated: true)
    }
    
    // MARK: - Helpers
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension UsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        let user = viewModel.users[indexPath.row]
        cell.configure(with: user)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension UsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = viewModel.users[indexPath.row]
        let editVC = EditUserViewController(user: user)
        editVC.onUserUpdated = { [weak self] in
            self?.viewModel.loadUsers()
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let user = viewModel.users[indexPath.row]
        
        // No permitir eliminar al admin principal
        guard user.role != .admin || viewModel.users.filter({ $0.role == .admin }).count > 1 else {
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Eliminar") { [weak self] _, _, completion in
            self?.confirmDelete(user: user)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func confirmDelete(user: User) {
        let alert = UIAlertController(
            title: "Eliminar usuario",
            message: "¿Estás seguro de eliminar a \(user.nombreCompleto)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Eliminar", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteUser(user)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UserCell

class UserCell: UITableViewCell {
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let roleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(statusView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(roleLabel)
        
        NSLayoutConstraint.activate([
            statusView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusView.widthAnchor.constraint(equalToConstant: 10),
            statusView.heightAnchor.constraint(equalToConstant: 10),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: roleLabel.leadingAnchor, constant: -8),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            emailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            roleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            roleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            roleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            roleLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        accessoryType = .disclosureIndicator
    }
    
    func configure(with user: User) {
        nameLabel.text = user.nombreCompleto
        emailLabel.text = user.email
        roleLabel.text = "  \(user.role.rawValue)  "
        roleLabel.backgroundColor = user.role == .admin ? .systemBlue : .systemGreen
        statusView.backgroundColor = user.isActive ? .systemGreen : .systemRed
    }
}
