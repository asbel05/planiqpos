//
//  ProductoCell.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class ProductoCell: UITableViewCell {
    
    static let identifier = "ProductoCell"
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let productoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .systemGray5
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "cube.box.fill")
        iv.tintColor = .systemGray3
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let codigoLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 11, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descripcionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoriaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let precioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .systemGreen
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let estadoIndicator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = .tertiaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
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
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(productoImageView)
        containerView.addSubview(codigoLabel)
        containerView.addSubview(descripcionLabel)
        containerView.addSubview(categoriaLabel)
        containerView.addSubview(precioLabel)
        containerView.addSubview(estadoIndicator)
        containerView.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            productoImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            productoImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            productoImageView.widthAnchor.constraint(equalToConstant: 50),
            productoImageView.heightAnchor.constraint(equalToConstant: 50),
            
            estadoIndicator.topAnchor.constraint(equalTo: containerView.topAnchor),
            estadoIndicator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            estadoIndicator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            estadoIndicator.widthAnchor.constraint(equalToConstant: 4),
            
            codigoLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            codigoLabel.leadingAnchor.constraint(equalTo: productoImageView.trailingAnchor, constant: 12),
            
            descripcionLabel.topAnchor.constraint(equalTo: codigoLabel.bottomAnchor, constant: 2),
            descripcionLabel.leadingAnchor.constraint(equalTo: codigoLabel.leadingAnchor),
            descripcionLabel.trailingAnchor.constraint(equalTo: precioLabel.leadingAnchor, constant: -8),
            
            categoriaLabel.topAnchor.constraint(equalTo: descripcionLabel.bottomAnchor, constant: 4),
            categoriaLabel.leadingAnchor.constraint(equalTo: codigoLabel.leadingAnchor),
            categoriaLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10),
            
            precioLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            precioLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            precioLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: estadoIndicator.leadingAnchor, constant: -8),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with producto: Producto) {
        codigoLabel.text = producto.codigo
        descripcionLabel.text = producto.descripcion
        
        // Categoría • Marca
        var infoText = producto.categoriaNombre
        if producto.marca != nil {
            infoText += " • " + producto.marcaNombre
        }
        categoriaLabel.text = infoText
        
        // Precio
        precioLabel.text = producto.precioActivoFormateado
        
        // Imagen
        if let imageData = producto.imagen, let image = UIImage(data: imageData) {
            productoImageView.image = image
            productoImageView.contentMode = .scaleAspectFill
        }
        
        // Estado
        if producto.estado {
            estadoIndicator.backgroundColor = .systemGreen
            containerView.alpha = 1.0
        } else {
            estadoIndicator.backgroundColor = .systemRed
            containerView.alpha = 0.6
        }
    }
}
