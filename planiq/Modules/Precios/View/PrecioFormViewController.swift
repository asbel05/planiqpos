//
//  PrecioFormViewController.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class PrecioFormViewController: UIViewController {
    
    // MARK: - Properties
    
    private let producto: Producto
    private var precio: Precio?
    private let viewModel: PreciosViewModel
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // Header
    private let productHeaderView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let productNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let productCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Campos de precio
    private let precioUnitarioField = PrecioFormViewController.createNumberField(placeholder: "Precio Unitario *")
    private let precioMayoristaField = PrecioFormViewController.createNumberField(placeholder: "Precio Mayorista")
    private let costoNetoField = PrecioFormViewController.createNumberField(placeholder: "Costo Neto")
    private let costoBaseField = PrecioFormViewController.createNumberField(placeholder: "Costo Base")
    
    // Campos de unidades
    private let unidadMinimaField = PrecioFormViewController.createNumberField(placeholder: "Unidad Mínima")
    private let unidadCompraField = PrecioFormViewController.createNumberField(placeholder: "Unidad Compra")
    private let unidadBonificacionField = PrecioFormViewController.createNumberField(placeholder: "Bonificación")
    
    // Descuentos
    private let descuento1Field = PrecioFormViewController.createNumberField(placeholder: "Descuento 1 %")
    private let descuento2Field = PrecioFormViewController.createNumberField(placeholder: "Descuento 2 %")
    private let descuento3Field = PrecioFormViewController.createNumberField(placeholder: "Descuento 3 %")
    
    // Margen calculado
    private let margenContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemGreen.withAlphaComponent(0.1)
        v.layer.cornerRadius = 10
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let margenTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Margen de ganancia"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let margenValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0.0%"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let gananciaLabel: UILabel = {
        let label = UILabel()
        label.text = "Ganancia: S/ 0.00"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Estado
    private let estadoLabel: UILabel = {
        let label = UILabel()
        label.text = "Precio activo"
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let estadoSwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = true
        sw.onTintColor = .systemGreen
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()
    
    // Guardar
    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Guardar Precio", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = .systemGreen
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Init
    
    init(producto: Producto, precio: Precio?, viewModel: PreciosViewModel) {
        self.producto = producto
        self.precio = precio
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
        configureHeader()
        configureForEditing()
        setupActions()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = precio == nil ? "Nuevo Precio" : "Editar Precio"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Header del producto
        contentView.addSubview(productHeaderView)
        productHeaderView.addSubview(productCodeLabel)
        productHeaderView.addSubview(productNameLabel)
        
        // Campos principales
        contentView.addSubview(precioUnitarioField)
        contentView.addSubview(precioMayoristaField)
        contentView.addSubview(costoNetoField)
        contentView.addSubview(costoBaseField)
        
        // Margen
        contentView.addSubview(margenContainerView)
        margenContainerView.addSubview(margenTitleLabel)
        margenContainerView.addSubview(margenValueLabel)
        margenContainerView.addSubview(gananciaLabel)
        
        // Unidades
        contentView.addSubview(unidadMinimaField)
        contentView.addSubview(unidadCompraField)
        contentView.addSubview(unidadBonificacionField)
        
        // Descuentos
        contentView.addSubview(descuento1Field)
        contentView.addSubview(descuento2Field)
        contentView.addSubview(descuento3Field)
        
        // Estado
        contentView.addSubview(estadoLabel)
        contentView.addSubview(estadoSwitch)
        
        // Botón
        contentView.addSubview(saveButton)
        
        let fieldHeight: CGFloat = 50
        let spacing: CGFloat = 12
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header
            productHeaderView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            productHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            productHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            productHeaderView.heightAnchor.constraint(equalToConstant: 60),
            
            productCodeLabel.topAnchor.constraint(equalTo: productHeaderView.topAnchor, constant: 12),
            productCodeLabel.leadingAnchor.constraint(equalTo: productHeaderView.leadingAnchor, constant: 16),
            
            productNameLabel.topAnchor.constraint(equalTo: productCodeLabel.bottomAnchor, constant: 2),
            productNameLabel.leadingAnchor.constraint(equalTo: productCodeLabel.leadingAnchor),
            productNameLabel.trailingAnchor.constraint(equalTo: productHeaderView.trailingAnchor, constant: -16),
            
            // Precios principales
            precioUnitarioField.topAnchor.constraint(equalTo: productHeaderView.bottomAnchor, constant: 20),
            precioUnitarioField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            precioUnitarioField.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -6),
            precioUnitarioField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            precioMayoristaField.topAnchor.constraint(equalTo: precioUnitarioField.topAnchor),
            precioMayoristaField.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 6),
            precioMayoristaField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            precioMayoristaField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            costoNetoField.topAnchor.constraint(equalTo: precioUnitarioField.bottomAnchor, constant: spacing),
            costoNetoField.leadingAnchor.constraint(equalTo: precioUnitarioField.leadingAnchor),
            costoNetoField.trailingAnchor.constraint(equalTo: precioUnitarioField.trailingAnchor),
            costoNetoField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            costoBaseField.topAnchor.constraint(equalTo: costoNetoField.topAnchor),
            costoBaseField.leadingAnchor.constraint(equalTo: precioMayoristaField.leadingAnchor),
            costoBaseField.trailingAnchor.constraint(equalTo: precioMayoristaField.trailingAnchor),
            costoBaseField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // Margen
            margenContainerView.topAnchor.constraint(equalTo: costoNetoField.bottomAnchor, constant: 16),
            margenContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            margenContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            margenContainerView.heightAnchor.constraint(equalToConstant: 80),
            
            margenTitleLabel.topAnchor.constraint(equalTo: margenContainerView.topAnchor, constant: 12),
            margenTitleLabel.leadingAnchor.constraint(equalTo: margenContainerView.leadingAnchor, constant: 16),
            
            margenValueLabel.topAnchor.constraint(equalTo: margenTitleLabel.bottomAnchor, constant: 4),
            margenValueLabel.leadingAnchor.constraint(equalTo: margenTitleLabel.leadingAnchor),
            
            gananciaLabel.centerYAnchor.constraint(equalTo: margenContainerView.centerYAnchor),
            gananciaLabel.trailingAnchor.constraint(equalTo: margenContainerView.trailingAnchor, constant: -16),
            
            // Unidades
            unidadMinimaField.topAnchor.constraint(equalTo: margenContainerView.bottomAnchor, constant: 20),
            unidadMinimaField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            unidadMinimaField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3, constant: -padding),
            unidadMinimaField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            unidadCompraField.topAnchor.constraint(equalTo: unidadMinimaField.topAnchor),
            unidadCompraField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            unidadCompraField.widthAnchor.constraint(equalTo: unidadMinimaField.widthAnchor),
            unidadCompraField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            unidadBonificacionField.topAnchor.constraint(equalTo: unidadMinimaField.topAnchor),
            unidadBonificacionField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            unidadBonificacionField.widthAnchor.constraint(equalTo: unidadMinimaField.widthAnchor),
            unidadBonificacionField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // Descuentos
            descuento1Field.topAnchor.constraint(equalTo: unidadMinimaField.bottomAnchor, constant: spacing),
            descuento1Field.leadingAnchor.constraint(equalTo: unidadMinimaField.leadingAnchor),
            descuento1Field.widthAnchor.constraint(equalTo: unidadMinimaField.widthAnchor),
            descuento1Field.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            descuento2Field.topAnchor.constraint(equalTo: descuento1Field.topAnchor),
            descuento2Field.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            descuento2Field.widthAnchor.constraint(equalTo: descuento1Field.widthAnchor),
            descuento2Field.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            descuento3Field.topAnchor.constraint(equalTo: descuento1Field.topAnchor),
            descuento3Field.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            descuento3Field.widthAnchor.constraint(equalTo: descuento1Field.widthAnchor),
            descuento3Field.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // Estado
            estadoLabel.topAnchor.constraint(equalTo: descuento1Field.bottomAnchor, constant: 24),
            estadoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            
            estadoSwitch.centerYAnchor.constraint(equalTo: estadoLabel.centerYAnchor),
            estadoSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            // Botón guardar
            saveButton.topAnchor.constraint(equalTo: estadoLabel.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            saveButton.heightAnchor.constraint(equalToConstant: 54),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
        
        // Dismiss keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        // Actualizar margen en tiempo real
        precioUnitarioField.addTarget(self, action: #selector(updateMargen), for: .editingChanged)
        costoNetoField.addTarget(self, action: #selector(updateMargen), for: .editingChanged)
    }
    
    private func configureHeader() {
        productCodeLabel.text = producto.codigo
        productNameLabel.text = producto.descripcion
    }
    
    private func configureForEditing() {
        guard let precio = precio else {
            unidadMinimaField.text = "1"
            unidadCompraField.text = "1"
            return
        }
        
        precioUnitarioField.text = String(format: "%.2f", precio.precioUnitario)
        precioMayoristaField.text = String(format: "%.2f", precio.precioMayorista)
        costoNetoField.text = String(format: "%.2f", precio.costoNeto)
        costoBaseField.text = String(format: "%.2f", precio.costoBase)
        
        unidadMinimaField.text = "\(precio.unidadMinima)"
        unidadCompraField.text = "\(precio.unidadCompra)"
        unidadBonificacionField.text = "\(precio.unidadBonificacion)"
        
        descuento1Field.text = String(format: "%.1f", precio.descuento1)
        descuento2Field.text = String(format: "%.1f", precio.descuento2)
        descuento3Field.text = String(format: "%.1f", precio.descuento3)
        
        estadoSwitch.isOn = precio.esActivo
        
        updateMargen()
    }
    
    // MARK: - Actions
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func updateMargen() {
        let precioUnitario = Double(precioUnitarioField.text ?? "0") ?? 0
        let costoNeto = Double(costoNetoField.text ?? "0") ?? 0
        
        let ganancia = precioUnitario - costoNeto
        let margen = precioUnitario > 0 ? ((precioUnitario - costoNeto) / precioUnitario) * 100 : 0
        
        margenValueLabel.text = String(format: "%.1f%%", margen)
        gananciaLabel.text = String(format: "Ganancia: S/ %.2f", ganancia)
        
        // Colores según margen
        if margen >= 30 {
            margenValueLabel.textColor = .systemGreen
            margenContainerView.backgroundColor = .systemGreen.withAlphaComponent(0.1)
        } else if margen >= 15 {
            margenValueLabel.textColor = .systemBlue
            margenContainerView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        } else if margen > 0 {
            margenValueLabel.textColor = .systemOrange
            margenContainerView.backgroundColor = .systemOrange.withAlphaComponent(0.1)
        } else {
            margenValueLabel.textColor = .systemRed
            margenContainerView.backgroundColor = .systemRed.withAlphaComponent(0.1)
        }
    }
    
    @objc private func saveTapped() {
        let precioUnitario = Double(precioUnitarioField.text ?? "0") ?? 0
        let precioMayorista = Double(precioMayoristaField.text ?? "0") ?? 0
        let costoNeto = Double(costoNetoField.text ?? "0") ?? 0
        let costoBase = Double(costoBaseField.text ?? "0") ?? 0
        
        let unidadMinima = Int(unidadMinimaField.text ?? "1") ?? 1
        let unidadCompra = Int(unidadCompraField.text ?? "1") ?? 1
        let unidadBonificacion = Int(unidadBonificacionField.text ?? "0") ?? 0
        
        let descuento1 = Double(descuento1Field.text ?? "0") ?? 0
        let descuento2 = Double(descuento2Field.text ?? "0") ?? 0
        let descuento3 = Double(descuento3Field.text ?? "0") ?? 0
        
        if let precio = precio {
            viewModel.updatePrecio(
                precio,
                precioUnitario: precioUnitario,
                precioMayorista: precioMayorista,
                costoNeto: costoNeto,
                costoBase: costoBase,
                unidadMinima: unidadMinima,
                unidadCompra: unidadCompra,
                unidadBonificacion: unidadBonificacion,
                descuento1: descuento1,
                descuento2: descuento2,
                descuento3: descuento3,
                esActivo: estadoSwitch.isOn
            )
        } else {
            viewModel.addPrecio(
                producto: producto,
                precioUnitario: precioUnitario,
                precioMayorista: precioMayorista,
                costoNeto: costoNeto,
                costoBase: costoBase,
                unidadMinima: unidadMinima,
                unidadCompra: unidadCompra,
                unidadBonificacion: unidadBonificacion,
                descuento1: descuento1,
                descuento2: descuento2,
                descuento3: descuento3,
                esActivo: estadoSwitch.isOn
            )
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helpers
    
    private static func createNumberField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 15)
        tf.keyboardType = .decimalPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }
}
