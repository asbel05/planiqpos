//
//  PagoViewController.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class PagoViewController: UIViewController {
    
    // MARK: - Properties
    
    private let total: Double
    private let viewModel: VentaViewModel
    private var pagos: [(TipoPago, Double, String?)] = []
    
    // MARK: - UI Components
    
    private let totalHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let totalTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Total a Pagar"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let metodosPagoStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private lazy var efectivoButton = createMetodoButton(tipo: .efectivo)
    private lazy var tarjetaButton = createMetodoButton(tipo: .tarjeta)
    private lazy var yapeButton = createMetodoButton(tipo: .yape)
    
    private let montoTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Monto recibido"
        tf.font = .systemFont(ofSize: 24, weight: .bold)
        tf.textAlignment = .center
        tf.keyboardType = .decimalPad
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let vueltoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 10
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let vueltoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let confirmarButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Confirmar Pago", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.backgroundColor = .systemGreen
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private var metodoSeleccionado: TipoPago = .efectivo {
        didSet {
            updateMetodosUI()
        }
    }
    
    // MARK: - Init
    
    init(total: Double, viewModel: VentaViewModel) {
        self.total = total
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        montoTextField.text = String(format: "%.2f", total)
        updateVuelto()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(totalHeaderView)
        totalHeaderView.addSubview(totalTitleLabel)
        totalHeaderView.addSubview(totalValueLabel)
        
        view.addSubview(metodosPagoStack)
        metodosPagoStack.addArrangedSubview(efectivoButton)
        metodosPagoStack.addArrangedSubview(tarjetaButton)
        metodosPagoStack.addArrangedSubview(yapeButton)
        
        view.addSubview(montoTextField)
        view.addSubview(vueltoContainerView)
        vueltoContainerView.addSubview(vueltoLabel)
        view.addSubview(confirmarButton)
        
        totalValueLabel.text = String(format: "S/ %.2f", total)
        
        NSLayoutConstraint.activate([
            totalHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            totalHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            totalHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            totalHeaderView.heightAnchor.constraint(equalToConstant: 100),
            
            totalTitleLabel.topAnchor.constraint(equalTo: totalHeaderView.topAnchor, constant: 20),
            totalTitleLabel.centerXAnchor.constraint(equalTo: totalHeaderView.centerXAnchor),
            
            totalValueLabel.topAnchor.constraint(equalTo: totalTitleLabel.bottomAnchor, constant: 8),
            totalValueLabel.centerXAnchor.constraint(equalTo: totalHeaderView.centerXAnchor),
            
            metodosPagoStack.topAnchor.constraint(equalTo: totalHeaderView.bottomAnchor, constant: 24),
            metodosPagoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            metodosPagoStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            metodosPagoStack.heightAnchor.constraint(equalToConstant: 80),
            
            montoTextField.topAnchor.constraint(equalTo: metodosPagoStack.bottomAnchor, constant: 24),
            montoTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            montoTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            montoTextField.heightAnchor.constraint(equalToConstant: 60),
            
            vueltoContainerView.topAnchor.constraint(equalTo: montoTextField.bottomAnchor, constant: 16),
            vueltoContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            vueltoContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            vueltoContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            vueltoLabel.centerXAnchor.constraint(equalTo: vueltoContainerView.centerXAnchor),
            vueltoLabel.centerYAnchor.constraint(equalTo: vueltoContainerView.centerYAnchor),
            
            confirmarButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmarButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmarButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            confirmarButton.heightAnchor.constraint(equalToConstant: 54)
        ])
        
        efectivoButton.addTarget(self, action: #selector(efectivoTapped), for: .touchUpInside)
        tarjetaButton.addTarget(self, action: #selector(tarjetaTapped), for: .touchUpInside)
        yapeButton.addTarget(self, action: #selector(yapeTapped), for: .touchUpInside)
        montoTextField.addTarget(self, action: #selector(montoChanged), for: .editingChanged)
        confirmarButton.addTarget(self, action: #selector(confirmarTapped), for: .touchUpInside)
        
        updateMetodosUI()
    }
    
    private func createMetodoButton(tipo: TipoPago) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: tipo.icono), for: .normal)
        btn.setTitle(tipo.rawValue, for: .normal)
        btn.tintColor = .label
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.backgroundColor = .systemGray6
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 2
        btn.layer.borderColor = UIColor.clear.cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        var config = UIButton.Configuration.plain()
        config.imagePlacement = .top
        config.imagePadding = 8
        btn.configuration = config
        
        return btn
    }
    
    private func updateMetodosUI() {
        [efectivoButton, tarjetaButton, yapeButton].forEach { btn in
            btn.layer.borderColor = UIColor.clear.cgColor
            btn.backgroundColor = .systemGray6
        }
        
        let selectedButton: UIButton
        switch metodoSeleccionado {
        case .efectivo:
            selectedButton = efectivoButton
        case .tarjeta:
            selectedButton = tarjetaButton
        case .yape, .plin:
            selectedButton = yapeButton
        default:
            selectedButton = efectivoButton
        }
        
        selectedButton.layer.borderColor = UIColor.systemGreen.cgColor
        selectedButton.backgroundColor = .systemGreen.withAlphaComponent(0.1)
        
        // Mostrar vuelto solo en efectivo
        montoTextField.isEnabled = metodoSeleccionado == .efectivo
        vueltoContainerView.isHidden = metodoSeleccionado != .efectivo
        
        if metodoSeleccionado != .efectivo {
            montoTextField.text = String(format: "%.2f", total)
        }
    }
    
    private func updateVuelto() {
        let montoRecibido = Double(montoTextField.text ?? "0") ?? 0
        let vuelto = montoRecibido - total
        
        if vuelto >= 0 {
            vueltoLabel.text = "Vuelto: S/ \(String(format: "%.2f", vuelto))"
            vueltoLabel.textColor = .systemBlue
            confirmarButton.isEnabled = true
            confirmarButton.alpha = 1.0
        } else {
            vueltoLabel.text = "Falta: S/ \(String(format: "%.2f", abs(vuelto)))"
            vueltoLabel.textColor = .systemRed
            confirmarButton.isEnabled = metodoSeleccionado != .efectivo
            confirmarButton.alpha = metodoSeleccionado != .efectivo ? 1.0 : 0.5
        }
    }
    
    // MARK: - Actions
    
    @objc private func efectivoTapped() { metodoSeleccionado = .efectivo }
    @objc private func tarjetaTapped() { metodoSeleccionado = .tarjeta }
    @objc private func yapeTapped() { metodoSeleccionado = .yape }
    
    @objc private func montoChanged() {
        updateVuelto()
    }
    
    @objc private func confirmarTapped() {
        let montoRecibido = Double(montoTextField.text ?? "0") ?? total
        
        pagos = [(metodoSeleccionado, montoRecibido, nil)]
        
        let exito = viewModel.procesarVenta(pagos: pagos)
        
        if exito {
            dismiss(animated: true)
        }
    }
}
