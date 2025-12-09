//
//  EditUserViewController.swift
//  planiq
//
//  Created by Asbel on 8/12/25.
//

import UIKit

final class EditUserViewController: UIViewController {
    
    private lazy var viewModel: EditUserViewModel = {
        EditUserViewModel(user: user, modelContext: AppDelegate.sharedModelContainer.mainContext)
    }()
    
    private let user: User
    var onUserUpdated: (() -> Void)?
    
    // MARK: - UI
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private func makeField(_ placeholder: String, keyboard: UIKeyboardType = .default) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 0.4
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 45))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocorrectionType = .no
        tf.keyboardType = keyboard
        if keyboard == .emailAddress {
            tf.autocapitalizationType = .none
        } else {
            tf.autocapitalizationType = .words
        }
        return tf
    }
    
    private func makeLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private lazy var nombresLabel = makeLabel("Nombres")
    private lazy var nombresField = makeField("Ingresa los nombres")
    
    private lazy var apellidosLabel = makeLabel("Apellidos")
    private lazy var apellidosField = makeField("Ingresa los apellidos")
    
    private lazy var emailLabel = makeLabel("Correo electrónico")
    private lazy var emailField = makeField("ejemplo@correo.com", keyboard: .emailAddress)
    
    private lazy var celularLabel = makeLabel("Número de celular")
    private lazy var celularField = makeField("9 dígitos", keyboard: .phonePad)
    
    private lazy var roleLabel = makeLabel("Rol del usuario")
    private let roleSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Administrador", "Cajero"])
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    private lazy var statusLabel = makeLabel("Estado")
    private let statusSwitch: UISwitch = {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()
    
    private let statusDescLabel: UILabel = {
        let label = UILabel()
        label.text = "Usuario activo"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Guardar cambios", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let resetPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Restablecer contraseña", for: .normal)
        btn.setTitleColor(.systemOrange, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Init
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Editar Usuario"
        
        setupUI()
        setupConstraints()
        setupBindings()
        setupActions()
        loadUserData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [nombresLabel, nombresField,
         apellidosLabel, apellidosField,
         emailLabel, emailField,
         celularLabel, celularField,
         roleLabel, roleSegment,
         statusLabel, statusSwitch, statusDescLabel,
         saveButton, resetPasswordButton].forEach { contentView.addSubview($0) }
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 20
        let fieldHeight: CGFloat = 48
        let spacing: CGFloat = 8
        let sectionSpacing: CGFloat = 20
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            nombresLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            nombresLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            
            nombresField.topAnchor.constraint(equalTo: nombresLabel.bottomAnchor, constant: spacing),
            nombresField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            nombresField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            nombresField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            apellidosLabel.topAnchor.constraint(equalTo: nombresField.bottomAnchor, constant: sectionSpacing),
            apellidosLabel.leadingAnchor.constraint(equalTo: nombresLabel.leadingAnchor),
            
            apellidosField.topAnchor.constraint(equalTo: apellidosLabel.bottomAnchor, constant: spacing),
            apellidosField.leadingAnchor.constraint(equalTo: nombresField.leadingAnchor),
            apellidosField.trailingAnchor.constraint(equalTo: nombresField.trailingAnchor),
            apellidosField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            emailLabel.topAnchor.constraint(equalTo: apellidosField.bottomAnchor, constant: sectionSpacing),
            emailLabel.leadingAnchor.constraint(equalTo: nombresLabel.leadingAnchor),
            
            emailField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: spacing),
            emailField.leadingAnchor.constraint(equalTo: nombresField.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: nombresField.trailingAnchor),
            emailField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            celularLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: sectionSpacing),
            celularLabel.leadingAnchor.constraint(equalTo: nombresLabel.leadingAnchor),
            
            celularField.topAnchor.constraint(equalTo: celularLabel.bottomAnchor, constant: spacing),
            celularField.leadingAnchor.constraint(equalTo: nombresField.leadingAnchor),
            celularField.trailingAnchor.constraint(equalTo: nombresField.trailingAnchor),
            celularField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            roleLabel.topAnchor.constraint(equalTo: celularField.bottomAnchor, constant: sectionSpacing),
            roleLabel.leadingAnchor.constraint(equalTo: nombresLabel.leadingAnchor),
            
            roleSegment.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: spacing),
            roleSegment.leadingAnchor.constraint(equalTo: nombresField.leadingAnchor),
            roleSegment.trailingAnchor.constraint(equalTo: nombresField.trailingAnchor),
            roleSegment.heightAnchor.constraint(equalToConstant: 40),
            
            statusLabel.topAnchor.constraint(equalTo: roleSegment.bottomAnchor, constant: sectionSpacing),
            statusLabel.leadingAnchor.constraint(equalTo: nombresLabel.leadingAnchor),
            
            statusSwitch.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: spacing),
            statusSwitch.leadingAnchor.constraint(equalTo: nombresField.leadingAnchor),
            
            statusDescLabel.centerYAnchor.constraint(equalTo: statusSwitch.centerYAnchor),
            statusDescLabel.leadingAnchor.constraint(equalTo: statusSwitch.trailingAnchor, constant: 12),
            
            saveButton.topAnchor.constraint(equalTo: statusSwitch.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: nombresField.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: nombresField.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            resetPasswordButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 16),
            resetPasswordButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            resetPasswordButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            loadingIndicator.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: saveButton.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupBindings() {
        viewModel.onLoadingChange = { [weak self] loading in
            loading ? self?.loadingIndicator.startAnimating() : self?.loadingIndicator.stopAnimating()
            self?.saveButton.isEnabled = !loading
        }
        
        viewModel.onErrorMessage = { [weak self] msg in
            self?.showAlert(title: "Error", message: msg)
        }
        
        viewModel.onUserUpdated = { [weak self] in
            self?.onUserUpdated?()
            self?.navigationController?.popViewController(animated: true)
        }
        
        viewModel.onPasswordReset = { [weak self] in
            self?.showAlert(title: "Éxito", message: "Contraseña restablecida a 'admin123'")
        }
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        resetPasswordButton.addTarget(self, action: #selector(resetPasswordTapped), for: .touchUpInside)
        
        nombresField.addTarget(self, action: #selector(nombresChanged), for: .editingChanged)
        apellidosField.addTarget(self, action: #selector(apellidosChanged), for: .editingChanged)
        emailField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        celularField.addTarget(self, action: #selector(celularChanged), for: .editingChanged)
        roleSegment.addTarget(self, action: #selector(roleChanged), for: .valueChanged)
        statusSwitch.addTarget(self, action: #selector(statusChanged), for: .valueChanged)
    }
    
    private func loadUserData() {
        nombresField.text = user.nombres
        apellidosField.text = user.apellidos
        emailField.text = user.email
        celularField.text = user.celular
        roleSegment.selectedSegmentIndex = user.role == .admin ? 0 : 1
        statusSwitch.isOn = user.isActive
        statusDescLabel.text = user.isActive ? "Usuario activo" : "Usuario inactivo"
        
        viewModel.nombres = user.nombres
        viewModel.apellidos = user.apellidos
        viewModel.email = user.email
        viewModel.celular = user.celular
        viewModel.role = user.role
        viewModel.isActive = user.isActive
    }
    
    // MARK: - Actions
    
    @objc private func saveTapped() { viewModel.updateUser() }
    @objc private func nombresChanged() { viewModel.nombres = nombresField.text ?? "" }
    @objc private func apellidosChanged() { viewModel.apellidos = apellidosField.text ?? "" }
    @objc private func emailChanged() { viewModel.email = emailField.text ?? "" }
    @objc private func celularChanged() { viewModel.celular = celularField.text ?? "" }
    @objc private func roleChanged() {
        viewModel.role = roleSegment.selectedSegmentIndex == 0 ? .admin : .cashier
    }
    @objc private func statusChanged() {
        viewModel.isActive = statusSwitch.isOn
        statusDescLabel.text = statusSwitch.isOn ? "Usuario activo" : "Usuario inactivo"
    }
    
    @objc private func resetPasswordTapped() {
        let alert = UIAlertController(
            title: "Restablecer contraseña",
            message: "¿Estás seguro de restablecer la contraseña de \(user.nombreCompleto) a 'admin123'?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Restablecer", style: .destructive) { [weak self] _ in
            self?.viewModel.resetPassword()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Helpers
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alert, animated: true)
    }
}
