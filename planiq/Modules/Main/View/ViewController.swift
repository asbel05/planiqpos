//
//  ViewController.swift
//  planiq
//
//  Created by Asbel on 8/12/25.
//

import UIKit
import SwiftData

final class ViewController: UIViewController {
    
    private var currentUser: User?
    private var userRole: UserRole = .cashier
    
    // MARK: - UI
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Planiq POS"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let logoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Salir", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemGroupedBackground
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(ModuleCell.self, forCellWithReuseIdentifier: "ModuleCell")
        return cv
    }()
    
    private var modules: [Module] = []

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        
        loadUserData()
        setupUI()
        setupModules()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(usernameLabel)
        headerView.addSubview(logoutButton)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 120),
            
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            
            usernameLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12),
            usernameLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            logoutButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            logoutButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }
    
    private func loadUserData() {
        guard let userIdString = UserDefaults.standard.string(forKey: "currentUserId"),
              let userId = UUID(uuidString: userIdString),
              let roleString = UserDefaults.standard.string(forKey: "currentUserRole"),
              let role = UserRole(rawValue: roleString) else {
            return
        }
        
        userRole = role
        
        let context = AppDelegate.sharedModelContainer.mainContext
        let fetchDescriptor = FetchDescriptor<User>(
            predicate: #Predicate { user in
                user.id == userId
            }
        )
        
        Task { @MainActor in
            do {
                let users = try context.fetch(fetchDescriptor)
                if let user = users.first {
                    currentUser = user
                    usernameLabel.text = "(\(user.nombreCompleto))"
                }
            } catch {
                usernameLabel.text = "(Error)"
            }
        }
    }
    
    private func setupModules() {
        if userRole == .admin {
            // Admin ve todos los módulos
            modules = [
                Module(title: "Ventas", icon: "cart.fill", color: .systemGreen),
                Module(title: "Productos", icon: "cube.box.fill", color: .systemOrange),
                Module(title: "Categorías", icon: "folder.fill", color: .systemYellow),
                Module(title: "Marcas", icon: "tag.fill", color: .systemPurple),
                Module(title: "Unidades", icon: "scalemass.fill", color: .systemTeal),
                Module(title: "Precios", icon: "dollarsign.circle.fill", color: .systemGreen),
                Module(title: "Inventario", icon: "list.bullet.clipboard.fill", color: .systemIndigo),
                Module(title: "Reportes", icon: "chart.bar.fill", color: .systemPink),
                Module(title: "Usuarios", icon: "person.2.fill", color: .systemBlue)
            ]
        } else if userRole == .vendedor {
            // Vendedor ve módulos de venta e inventario
            modules = [
                Module(title: "Ventas", icon: "cart.fill", color: .systemGreen),
                Module(title: "Productos", icon: "cube.box.fill", color: .systemOrange),
                Module(title: "Inventario", icon: "list.bullet.clipboard.fill", color: .systemIndigo)
            ]
        } else {
            // Cajero solo ve módulos limitados
            modules = [
                Module(title: "Ventas", icon: "cart.fill", color: .systemGreen),
                Module(title: "Productos", icon: "cube.box.fill", color: .systemGray)
            ]
        }
        
        collectionView.reloadData()
    }
    
    // MARK: - Actions
    
    @objc private func logoutTapped() {
        UserDefaults.standard.removeObject(forKey: "currentUserId")
        UserDefaults.standard.removeObject(forKey: "currentUserRole")
        
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }
        
        let loginVC = LoginViewController()
        let navController = UINavigationController(rootViewController: loginVC)
        window.rootViewController = navController
        window.makeKeyAndVisible()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modules.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ModuleCell", for: indexPath) as! ModuleCell
        cell.configure(with: modules[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let module = modules[indexPath.item]
        
        var viewController: UIViewController?
        
        switch module.title {
        case "Usuarios":
            viewController = UsersViewController()
        case "Productos":
            viewController = ProductosViewController()
        case "Categorías":
            viewController = CategoriasViewController()
        case "Marcas":
            viewController = MarcasViewController()
        case "Unidades":
            viewController = UnidadesViewController()
        case "Precios":
            viewController = PreciosViewController()
        default:
            let alert = UIAlertController(title: module.title, message: "Módulo en desarrollo", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        if let vc = viewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 20
        let spacing: CGFloat = 16
        let availableWidth = collectionView.bounds.width - (padding * 2) - spacing
        let width = availableWidth / 2
        return CGSize(width: width, height: 140)
    }
}

// MARK: - Module Model

struct Module {
    let title: String
    let icon: String
    let color: UIColor
}

// MARK: - ModuleCell

class ModuleCell: UICollectionViewCell {
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -15),
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    func configure(with module: Module) {
        titleLabel.text = module.title
        iconImageView.image = UIImage(systemName: module.icon)
        contentView.backgroundColor = module.color
    }
}
