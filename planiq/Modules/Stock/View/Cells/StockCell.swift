//
//  StockCell.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class StockCell: UITableViewCell {
    
    static let identifier = "StockCell"
    
    // MARK: - UI Components
    
    private let estadoIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cantidadLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let unidadLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let estadoBadge: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let estadoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 9, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        containerView.addSubview(estadoIndicator)
        containerView.addSubview(productoImageView)
        containerView.addSubview(codigoLabel)
        containerView.addSubview(descripcionLabel)
        containerView.addSubview(cantidadLabel)
        containerView.addSubview(unidadLabel)
        containerView.addSubview(estadoBadge)
        estadoBadge.addSubview(estadoLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            estadoIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            estadoIndicator.topAnchor.constraint(equalTo: containerView.topAnchor),
            estadoIndicator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            estadoIndicator.widthAnchor.constraint(equalToConstant: 4),
            
            productoImageView.leadingAnchor.constraint(equalTo: estadoIndicator.trailingAnchor, constant: 12),
            productoImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            productoImageView.widthAnchor.constraint(equalToConstant: 45),
            productoImageView.heightAnchor.constraint(equalToConstant: 45),
            
            codigoLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            codigoLabel.leadingAnchor.constraint(equalTo: productoImageView.trailingAnchor, constant: 12),
            
            descripcionLabel.topAnchor.constraint(equalTo: codigoLabel.bottomAnchor, constant: 2),
            descripcionLabel.leadingAnchor.constraint(equalTo: codigoLabel.leadingAnchor),
            descripcionLabel.trailingAnchor.constraint(equalTo: cantidadLabel.leadingAnchor, constant: -8),
            
            estadoBadge.topAnchor.constraint(equalTo: descripcionLabel.bottomAnchor, constant: 4),
            estadoBadge.leadingAnchor.constraint(equalTo: codigoLabel.leadingAnchor),
            estadoBadge.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10),
            estadoBadge.heightAnchor.constraint(equalToConstant: 16),
            
            estadoLabel.topAnchor.constraint(equalTo: estadoBadge.topAnchor, constant: 2),
            estadoLabel.bottomAnchor.constraint(equalTo: estadoBadge.bottomAnchor, constant: -2),
            estadoLabel.leadingAnchor.constraint(equalTo: estadoBadge.leadingAnchor, constant: 6),
            estadoLabel.trailingAnchor.constraint(equalTo: estadoBadge.trailingAnchor, constant: -6),
            
            cantidadLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -8),
            cantidadLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            cantidadLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            unidadLabel.topAnchor.constraint(equalTo: cantidadLabel.bottomAnchor, constant: 0),
            unidadLabel.trailingAnchor.constraint(equalTo: cantidadLabel.trailingAnchor)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with producto: Producto) {
        codigoLabel.text = producto.codigo
        descripcionLabel.text = producto.descripcion
        cantidadLabel.text = "\(producto.stockActual)"
        unidadLabel.text = producto.unidadAbreviatura
        
        // Imagen
        if let imageData = producto.imagen, let image = UIImage(data: imageData) {
            productoImageView.image = image
            productoImageView.contentMode = .scaleAspectFill
        }
        
        // Estado de stock
        let estado = producto.estadoStock
        estadoLabel.text = estado.rawValue.uppercased()
        
        switch estado {
        case .sinStock:
            estadoIndicator.backgroundColor = .systemRed
            estadoBadge.backgroundColor = .systemRed
            cantidadLabel.textColor = .systemRed
        case .bajo:
            estadoIndicator.backgroundColor = .systemOrange
            estadoBadge.backgroundColor = .systemOrange
            cantidadLabel.textColor = .systemOrange
        case .normal:
            estadoIndicator.backgroundColor = .systemGreen
            estadoBadge.backgroundColor = .systemGreen
            cantidadLabel.textColor = .systemGreen
        case .alto:
            estadoIndicator.backgroundColor = .systemBlue
            estadoBadge.backgroundColor = .systemBlue
            cantidadLabel.textColor = .systemBlue
        }
    }
}
