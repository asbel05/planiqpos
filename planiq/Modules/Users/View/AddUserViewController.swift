//
//  AddUserViewController.swift
//  planiq
//
//  Created by Asbel on 8/12/25.
//

import UIKit

final class AddUserViewController: UIViewController {
    
    private lazy var viewModel = AddUserViewModel(modelContext: AppDelegate.sharedModelContainer.mainContext)
    
    var onUserAdded: (() -> Void)?
    
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
    
    private func makeField(_ placeholder: String, secure: Bool = false, keyboard: UIKeyboardType = .default) -> UITextField {
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
        if secure {
            tf.isSecureTextEntry = true
            tf.textContentType = .oneTimeCode
            tf.autocapitalizationType = .none
        } else if keyboard == .emailAddress {
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
    
    private lazy var passwordLabel = makeLabel("Contraseña")
    private lazy var passwordField = makeField("Mínimo 6 caracteres", secure: true)
    
    private lazy var confirmPasswordLabel = makeLabel("Confirmar contraseña")
    private lazy var confirmPasswordField = makeField("Repite la contraseña", secure: true)
    
    private lazy var roleLabel = makeLabel("Rol del usuario")
    private let roleSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Administrador", "Cajero"])
        segment.selectedSegmentIndex = 1
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Guardar usuario", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Nuevo Usuario"
        
        setupNavigation()
        setupUI()
        setupConstraints()
        setupBindings()
        setupActions()
    }
    
    // MARK: - Setup
    
    private func setupNavigation() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [nombresLabel, nombresField,
         apellidosLabel, apellidosField,
         emailLabel, emailField,
         celularLabel, celularField,
         passwordLabel, passwordField,
         confirmPasswordLabel, confirmPasswordField,
         roleLabel, roleSegment,
         saveButton].forEach { contentView.addSubview($0) }
        
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
            
            passwordLabel.topAnchor.constraint(equalTo: celularField.bottomAnchor, constant: sectionSpacing),
            passwordLabel.leadingAnchor.constraint(equalTo: nombresLabel.leadingAnchor),
            
            passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: spacing),
            passwordField.leadingAnchor.constraint(equalTo: nombresField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: nombresField.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            confirmPasswordLabel.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: sectionSpacing),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: nombresLabel.leadingAnchor),
            
            confirmPasswordField.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: spacing),
            confirmPasswordField.leadingAnchor.constraint(equalTo: nombresField.leadingAnchor),
            confirmPasswordField.trailingAnchor.constraint(equalTo: nombresField.trailingAnchor),
            confirmPasswordField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            roleLabel.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: sectionSpacing),
            roleLabel.leadingAnchor.constraint(equalTo: nombresLabel.leadingAnchor),
            
            roleSegment.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: spacing),
            roleSegment.leadingAnchor.constraint(equalTo: nombresField.leadingAnchor),
            roleSegment.trailingAnchor.constraint(equalTo: nombresField.trailingAnchor),
            roleSegment.heightAnchor.constraint(equalToConstant: 40),
            
            saveButton.topAnchor.constraint(equalTo: roleSegment.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: nombresField.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: nombresField.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            loadingIndicator.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: saveButton.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupBindings() {
        viewModel.onFormValidChange = { [weak self] valid in
            self?.saveButton.alpha = valid ? 1 : 0.5
            self?.saveButton.isEnabled = valid
        }
        
        viewModel.onLoadingChange = { [weak self] loading in
            loading ? self?.loadingIndicator.startAnimating() : self?.loadingIndicator.stopAnimating()
            self?.saveButton.isEnabled = !loading
        }
        
        viewModel.onErrorMessage = { [weak self] msg in
            self?.showAlert(msg)
        }
        
        viewModel.onUserCreated = { [weak self] in
            self?.onUserAdded?()
            self?.dismiss(animated: true)
        }
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        nombresField.addTarget(self, action: #selector(nombresChanged), for: .editingChanged)
        apellidosField.addTarget(self, action: #selector(apellidosChanged), for: .editingChanged)
        emailField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        celularField.addTarget(self, action: #selector(celularChanged), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        confirmPasswordField.addTarget(self, action: #selector(confirmPasswordChanged), for: .editingChanged)
        roleSegment.addTarget(self, action: #selector(roleChanged), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() { viewModel.createUser() }
    @objc private func nombresChanged() { viewModel.nombres = nombresField.text ?? "" }
    @objc private func apellidosChanged() { viewModel.apellidos = apellidosField.text ?? "" }
    @objc private func emailChanged() { viewModel.email = emailField.text ?? "" }
    @objc private func celularChanged() { viewModel.celular = celularField.text ?? "" }
    @objc private func passwordChanged() { viewModel.password = passwordField.text ?? "" }
    @objc private func confirmPasswordChanged() { viewModel.confirmPassword = confirmPasswordField.text ?? "" }
    @objc private func roleChanged() {
        viewModel.role = roleSegment.selectedSegmentIndex == 0 ? .admin : .cashier
    }
    
    // MARK: - Helpers
    
    private func showAlert(_ msg: String) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alert, animated: true)
    }
}
