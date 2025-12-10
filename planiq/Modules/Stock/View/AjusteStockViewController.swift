//
//  AjusteStockViewController.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class AjusteStockViewController: UIViewController {
    
    // MARK: - Properties
    
    private let producto: Producto
    private let viewModel: StockViewModel
    private var tipoSeleccionado: TipoMovimiento = .entrada
    
    // MARK: - UI Components
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let productoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stockActualLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["Entrada", "Salida", "Ajuste"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private let cantidadTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "0"
        tf.font = .systemFont(ofSize: 48, weight: .bold)
        tf.textAlignment = .center
        tf.keyboardType = .numberPad
        tf.borderStyle = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let previewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGreen
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let motivoTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Motivo del ajuste *"
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let guardarButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Guardar Ajuste", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = .systemGreen
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Init
    
    init(producto: Producto, viewModel: StockViewModel) {
        self.producto = producto
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
        configureData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(headerView)
        headerView.addSubview(productoLabel)
        headerView.addSubview(stockActualLabel)
        view.addSubview(segmentedControl)
        view.addSubview(cantidadTextField)
        view.addSubview(previewLabel)
        view.addSubview(motivoTextField)
        view.addSubview(guardarButton)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            productoLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            productoLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            productoLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            stockActualLabel.topAnchor.constraint(equalTo: productoLabel.bottomAnchor, constant: 2),
            stockActualLabel.leadingAnchor.constraint(equalTo: productoLabel.leadingAnchor),
            
            segmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            cantidadTextField.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 24),
            cantidadTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cantidadTextField.widthAnchor.constraint(equalToConstant: 150),
            
            previewLabel.topAnchor.constraint(equalTo: cantidadTextField.bottomAnchor, constant: 8),
            previewLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            motivoTextField.topAnchor.constraint(equalTo: previewLabel.bottomAnchor, constant: 24),
            motivoTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            motivoTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            motivoTextField.heightAnchor.constraint(equalToConstant: 50),
            
            guardarButton.topAnchor.constraint(equalTo: motivoTextField.bottomAnchor, constant: 24),
            guardarButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            guardarButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            guardarButton.heightAnchor.constraint(equalToConstant: 54)
        ])
        
        segmentedControl.addTarget(self, action: #selector(tipoChanged), for: .valueChanged)
        cantidadTextField.addTarget(self, action: #selector(cantidadChanged), for: .editingChanged)
        guardarButton.addTarget(self, action: #selector(guardarTapped), for: .touchUpInside)
        
        cantidadTextField.becomeFirstResponder()
    }
    
    private func configureData() {
        productoLabel.text = producto.descripcion
        stockActualLabel.text = "Stock actual: \(producto.stockFormateado)"
        updatePreview()
    }
    
    // MARK: - Actions
    
    @objc private func tipoChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            tipoSeleccionado = .entrada
        case 1:
            tipoSeleccionado = .salida
        case 2:
            tipoSeleccionado = .ajuste
        default:
            break
        }
        updatePreview()
    }
    
    @objc private func cantidadChanged() {
        updatePreview()
    }
    
    private func updatePreview() {
        let cantidad = Int(cantidadTextField.text ?? "0") ?? 0
        let stockActual = producto.stockActual
        
        var nuevoStock: Int
        switch tipoSeleccionado {
        case .entrada, .devolucion:
            nuevoStock = stockActual + cantidad
            previewLabel.textColor = .systemGreen
        case .salida, .venta:
            nuevoStock = max(0, stockActual - cantidad)
            previewLabel.textColor = cantidad > stockActual ? .systemRed : .systemOrange
        case .ajuste:
            nuevoStock = cantidad
            previewLabel.textColor = .systemBlue
        }
        
        previewLabel.text = "Nuevo stock: \(nuevoStock) \(producto.unidadAbreviatura)"
    }
    
    @objc private func guardarTapped() {
        guard let cantidadStr = cantidadTextField.text,
              let cantidad = Int(cantidadStr),
              cantidad > 0 else {
            showAlert(message: "Ingresa una cantidad válida")
            return
        }
        
        let motivo = motivoTextField.text ?? ""
        if motivo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showAlert(message: "El motivo es obligatorio")
            return
        }
        
        let usuario = viewModel.getCurrentUser()
        viewModel.ajustarStock(
            producto: producto,
            tipo: tipoSeleccionado,
            cantidad: cantidad,
            motivo: motivo,
            usuario: usuario
        )
        
        dismiss(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
