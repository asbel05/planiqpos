//
//  SetupViewController.swift
//  planiq
//
//  Created by Asbel on 8/12/25.
//

import UIKit

final class SetupViewController: UIViewController {
    
    private lazy var viewModel = SetupViewModel(modelContext: AppDelegate.sharedModelContainer.mainContext)
    
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Configuración Inicial"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Crea la cuenta de administrador para comenzar a usar Planiq POS"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    private lazy var nombresField = makeField("Nombres")
    private lazy var apellidosField = makeField("Apellidos")
    private lazy var emailField = makeField("Correo electrónico", keyboard: .emailAddress)
    private lazy var celularField = makeField("Número de celular", keyboard: .phonePad)
    private lazy var passwordField = makeField("Contraseña", secure: true)
    private lazy var confirmPasswordField = makeField("Confirmar contraseña", secure: true)
    
    private let createButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Crear cuenta de administrador", for: .normal)
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
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        setupBindings()
        setupActions()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(nombresField)
        contentView.addSubview(apellidosField)
        contentView.addSubview(emailField)
        contentView.addSubview(celularField)
        contentView.addSubview(passwordField)
        contentView.addSubview(confirmPasswordField)
        contentView.addSubview(createButton)
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        createButton.addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
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
            
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            nombresField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            nombresField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            nombresField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22),
            nombresField.heightAnchor.constraint(equalToConstant: 48),
            
            apellidosField.topAnchor.constraint(equalTo: nombresField.bottomAnchor, constant: 14),
            apellidosField.leadingAnchor.constraint(equalTo: nombresField.leadingAnchor),
            apellidosField.trailingAnchor.constraint(equalTo: nombresField.trailingAnchor),
            apellidosField.heightAnchor.constraint(equalToConstant: 48),
            
            emailField.topAnchor.constraint(equalTo: apellidosField.bottomAnchor, constant: 14),
            emailField.leadingAnchor.constraint(equalTo: nombresField.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: nombresField.trailingAnchor),
            emailField.heightAnchor.constraint(equalToConstant: 48),
            
            celularField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 14),
            celularField.leadingAnchor.constraint(equalTo: nombresField.leadingAnchor),
            celularField.trailingAnchor.constraint(equalTo: nombresField.trailingAnchor),
            celularField.heightAnchor.constraint(equalToConstant: 48),
            
            passwordField.topAnchor.constraint(equalTo: celularField.bottomAnchor, constant: 14),
            passwordField.leadingAnchor.constraint(equalTo: nombresField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: nombresField.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 48),
            
            confirmPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 14),
            confirmPasswordField.leadingAnchor.constraint(equalTo: nombresField.leadingAnchor),
            confirmPasswordField.trailingAnchor.constraint(equalTo: nombresField.trailingAnchor),
            confirmPasswordField.heightAnchor.constraint(equalToConstant: 48),
            
            createButton.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 28),
            createButton.leadingAnchor.constraint(equalTo: nombresField.leadingAnchor),
            createButton.trailingAnchor.constraint(equalTo: nombresField.trailingAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 48),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            loadingIndicator.centerYAnchor.constraint(equalTo: createButton.centerYAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: createButton.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupBindings() {
        viewModel.onFormValidChange = { [weak self] valid in
            self?.createButton.alpha = valid ? 1 : 0.5
            self?.createButton.isEnabled = valid
        }
        
        viewModel.onLoadingChange = { [weak self] loading in
            loading ? self?.loadingIndicator.startAnimating() : self?.loadingIndicator.stopAnimating()
            self?.createButton.isEnabled = !loading
        }
        
        viewModel.onErrorMessage = { [weak self] msg in
            self?.showAlert(msg)
        }
        
        viewModel.onSetupSuccess = {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else { return }
            
            let loginVC = LoginViewController()
            let navController = UINavigationController(rootViewController: loginVC)
            window.rootViewController = navController
            window.makeKeyAndVisible()
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
    
    private func setupActions() {
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        
        nombresField.addTarget(self, action: #selector(nombresChanged), for: .editingChanged)
        apellidosField.addTarget(self, action: #selector(apellidosChanged), for: .editingChanged)
        emailField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        celularField.addTarget(self, action: #selector(celularChanged), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        confirmPasswordField.addTarget(self, action: #selector(confirmPasswordChanged), for: .editingChanged)
    }
    
    // MARK: - Actions
    
    @objc private func createTapped() { viewModel.createAdmin() }
    @objc private func nombresChanged() { viewModel.nombres = nombresField.text ?? "" }
    @objc private func apellidosChanged() { viewModel.apellidos = apellidosField.text ?? "" }
    @objc private func emailChanged() { viewModel.email = emailField.text ?? "" }
    @objc private func celularChanged() { viewModel.celular = celularField.text ?? "" }
    @objc private func passwordChanged() { viewModel.password = passwordField.text ?? "" }
    @objc private func confirmPasswordChanged() { viewModel.confirmPassword = confirmPasswordField.text ?? "" }
    
    // MARK: - Helpers
    
    private func showAlert(_ msg: String) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alert, animated: true)
    }
}
