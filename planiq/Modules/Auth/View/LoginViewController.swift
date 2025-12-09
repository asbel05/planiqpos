//
//  LoginViewController.swift
//  planiq
//
//  Created by Asbel on 8/12/25.
//

import UIKit

final class LoginViewController: UIViewController {

    private lazy var viewModel = LoginViewModel(modelContext: AppDelegate.sharedModelContainer.mainContext)

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Planiq"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sistema de Punto de Venta"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private func field(_ placeholder: String, secure: Bool = false) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 0.4
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 45))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        if secure {
            tf.isSecureTextEntry = true
            tf.textContentType = .oneTimeCode
        }
        return tf
    }

    private lazy var emailField = field("Correo electrónico")
    private lazy var passwordField = field("Contraseña", secure: true)

    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Iniciar sesión", for: .normal)
        btn.backgroundColor = UIColor.systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return btn
    }()

    private let forgotPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Olvidé mi contraseña", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let loadingIndicator = UIActivityIndicatorView(style: .medium)


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        setupConstraints()
        setupBindings()
        setupActions()
    }


    // MARK: - UI Setup

    private func configureUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(forgotPasswordButton)

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addSubview(loadingIndicator)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            emailField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 50),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22),
            emailField.heightAnchor.constraint(equalToConstant: 48),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 48),

            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 28),
            loginButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),

            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            loadingIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor, constant: -16)
        ])
    }


    // MARK: - Bindings / Actions

    private func setupBindings() {
        viewModel.onFormValidChange = { [weak self] valid in
            self?.loginButton.alpha = valid ? 1 : 0.5
        }

        viewModel.onLoadingChange = { [weak self] loading in
            loading ? self?.loadingIndicator.startAnimating() : self?.loadingIndicator.stopAnimating()
            self?.loginButton.isEnabled = !loading
        }

        viewModel.onErrorMessage = { [weak self] msg in self?.showAlert(msg) }

        viewModel.onLoginSuccess = { [weak self] user in
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else { return }
            
            UserDefaults.standard.set(user.id.uuidString, forKey: "currentUserId")
            UserDefaults.standard.set(user.role.rawValue, forKey: "currentUserRole")
            
            let mainVC = UINavigationController(rootViewController: ViewController())
            window.rootViewController = mainVC
            window.makeKeyAndVisible()
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
        
        viewModel.onPasswordResetSuccess = { [weak self] in
            self?.showAlert("Contraseña restablecida a 'admin123'")
        }
    }

    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)

        emailField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
    }


    // MARK: - Actions

    @objc private func loginTapped() { viewModel.loginWithEmail() }
    
    @objc private func forgotPasswordTapped() {
        let alert = UIAlertController(
            title: "Recuperar contraseña",
            message: "Ingresa tu correo electrónico para restablecer tu contraseña a 'admin123'",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Correo electrónico"
            textField.keyboardType = .emailAddress
            textField.autocapitalizationType = .none
        }
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Restablecer", style: .default) { [weak self] _ in
            guard let email = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !email.isEmpty else {
                self?.showAlert("Ingresa un correo válido.")
                return
            }
            
            self?.viewModel.resetPassword(email: email)
        })
        
        present(alert, animated: true)
    }

    @objc private func emailChanged() { viewModel.email = emailField.text ?? "" }
    @objc private func passwordChanged() { viewModel.password = passwordField.text ?? "" }


    // MARK: - Helpers

    private func showAlert(_ msg: String) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alert, animated: true)
    }
}
