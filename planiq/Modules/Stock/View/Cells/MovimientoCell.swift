//
//  MovimientoCell.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class MovimientoCell: UITableViewCell {
    
    static let identifier = "MovimientoCell"
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let tipoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cantidadLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cambioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let motivoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let fechaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = .tertiaryLabel
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usuarioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = .tertiaryLabel
        label.textAlignment = .right
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
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        containerView.addSubview(tipoLabel)
        containerView.addSubview(cantidadLabel)
        containerView.addSubview(cambioLabel)
        containerView.addSubview(motivoLabel)
        containerView.addSubview(fechaLabel)
        containerView.addSubview(usuarioLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            iconContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 36),
            iconContainer.heightAnchor.constraint(equalToConstant: 36),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),
            
            tipoLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            tipoLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            
            cantidadLabel.centerYAnchor.constraint(equalTo: tipoLabel.centerYAnchor),
            cantidadLabel.leadingAnchor.constraint(equalTo: tipoLabel.trailingAnchor, constant: 8),
            
            cambioLabel.topAnchor.constraint(equalTo: tipoLabel.bottomAnchor, constant: 2),
            cambioLabel.leadingAnchor.constraint(equalTo: tipoLabel.leadingAnchor),
            
            motivoLabel.topAnchor.constraint(equalTo: cambioLabel.bottomAnchor, constant: 2),
            motivoLabel.leadingAnchor.constraint(equalTo: tipoLabel.leadingAnchor),
            motivoLabel.trailingAnchor.constraint(equalTo: fechaLabel.leadingAnchor, constant: -8),
            motivoLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10),
            
            fechaLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            fechaLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            usuarioLabel.topAnchor.constraint(equalTo: fechaLabel.bottomAnchor, constant: 2),
            usuarioLabel.trailingAnchor.constraint(equalTo: fechaLabel.trailingAnchor)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with movimiento: MovimientoStock) {
        tipoLabel.text = movimiento.tipo.rawValue
        cantidadLabel.text = movimiento.cantidadConSigno
        cambioLabel.text = movimiento.cambioFormateado
        motivoLabel.text = movimiento.motivo ?? "---"
        fechaLabel.text = movimiento.fechaFormateada
        usuarioLabel.text = movimiento.usuarioNombre
        
        iconImageView.image = UIImage(systemName: movimiento.tipo.icono)
        
        switch movimiento.tipo {
        case .entrada, .devolucion:
            iconContainer.backgroundColor = .systemGreen
            tipoLabel.textColor = .systemGreen
            cantidadLabel.textColor = .systemGreen
        case .salida, .venta:
            iconContainer.backgroundColor = .systemRed
            tipoLabel.textColor = .systemRed
            cantidadLabel.textColor = .systemRed
        case .ajuste:
            iconContainer.backgroundColor = .systemBlue
            tipoLabel.textColor = .systemBlue
            cantidadLabel.textColor = .systemBlue
        }
    }
}
