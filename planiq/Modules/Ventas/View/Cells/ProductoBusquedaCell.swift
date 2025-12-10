//
//  ProductoBusquedaCell.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class ProductoBusquedaCell: UITableViewCell {
    
    static let identifier = "ProductoBusquedaCell"
    
    // MARK: - Callback
    var onAgregarTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let productoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .systemGray5
        iv.layer.cornerRadius = 6
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "cube.box.fill")
        iv.tintColor = .systemGray3
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let codigoLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 10, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nombreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stockLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let precioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let agregarButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        btn.tintColor = .systemGreen
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productoImageView.image = UIImage(systemName: "cube.box.fill")
        productoImageView.tintColor = .systemGray3
        productoImageView.contentMode = .scaleAspectFit
        onAgregarTapped = nil
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(productoImageView)
        containerView.addSubview(codigoLabel)
        containerView.addSubview(nombreLabel)
        containerView.addSubview(stockLabel)
        containerView.addSubview(precioLabel)
        containerView.addSubview(agregarButton)
        
        agregarButton.addTarget(self, action: #selector(agregarTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            productoImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            productoImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            productoImageView.widthAnchor.constraint(equalToConstant: 40),
            productoImageView.heightAnchor.constraint(equalToConstant: 40),
            
            codigoLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            codigoLabel.leadingAnchor.constraint(equalTo: productoImageView.trailingAnchor, constant: 10),
            
            nombreLabel.topAnchor.constraint(equalTo: codigoLabel.bottomAnchor, constant: 2),
            nombreLabel.leadingAnchor.constraint(equalTo: codigoLabel.leadingAnchor),
            nombreLabel.trailingAnchor.constraint(equalTo: precioLabel.leadingAnchor, constant: -8),
            
            stockLabel.topAnchor.constraint(equalTo: nombreLabel.bottomAnchor, constant: 2),
            stockLabel.leadingAnchor.constraint(equalTo: codigoLabel.leadingAnchor),
            stockLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10),
            
            precioLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            precioLabel.trailingAnchor.constraint(equalTo: agregarButton.leadingAnchor, constant: -12),
            
            agregarButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            agregarButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            agregarButton.widthAnchor.constraint(equalToConstant: 32),
            agregarButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    @objc private func agregarTapped() {
        onAgregarTapped?()
    }
    
    // MARK: - Configure
    
    func configure(with producto: Producto) {
        codigoLabel.text = producto.codigo
        nombreLabel.text = producto.descripcion
        precioLabel.text = producto.precioActivoFormateado
        
        // Imagen
        if let imageData = producto.imagen, let image = UIImage(data: imageData) {
            productoImageView.image = image
            productoImageView.contentMode = .scaleAspectFill
        }
        
        // Stock
        let stock = producto.stockActual
        if stock > 0 {
            stockLabel.text = "Stock: \(stock) \(producto.unidadAbreviatura)"
            stockLabel.textColor = .systemGreen
            agregarButton.isEnabled = true
            agregarButton.alpha = 1.0
        } else {
            stockLabel.text = "Sin stock"
            stockLabel.textColor = .systemRed
            agregarButton.isEnabled = false
            agregarButton.alpha = 0.3
        }
    }
}
