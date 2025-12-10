//
//  PrecioCell.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class PrecioCell: UITableViewCell {
    
    static let identifier = "PrecioCell"
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let precioUnitarioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let costoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let margenBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue.withAlphaComponent(0.15)
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let margenLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activoBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let activoLabel: UILabel = {
        let label = UILabel()
        label.text = "ACTIVO"
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let fechaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = .tertiaryLabel
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
        containerView.addSubview(precioUnitarioLabel)
        containerView.addSubview(costoLabel)
        containerView.addSubview(margenBadge)
        margenBadge.addSubview(margenLabel)
        containerView.addSubview(activoBadge)
        activoBadge.addSubview(activoLabel)
        containerView.addSubview(fechaLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            precioUnitarioLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            precioUnitarioLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            activoBadge.centerYAnchor.constraint(equalTo: precioUnitarioLabel.centerYAnchor),
            activoBadge.leadingAnchor.constraint(equalTo: precioUnitarioLabel.trailingAnchor, constant: 8),
            activoBadge.heightAnchor.constraint(equalToConstant: 18),
            
            activoLabel.topAnchor.constraint(equalTo: activoBadge.topAnchor, constant: 2),
            activoLabel.bottomAnchor.constraint(equalTo: activoBadge.bottomAnchor, constant: -2),
            activoLabel.leadingAnchor.constraint(equalTo: activoBadge.leadingAnchor, constant: 6),
            activoLabel.trailingAnchor.constraint(equalTo: activoBadge.trailingAnchor, constant: -6),
            
            costoLabel.topAnchor.constraint(equalTo: precioUnitarioLabel.bottomAnchor, constant: 4),
            costoLabel.leadingAnchor.constraint(equalTo: precioUnitarioLabel.leadingAnchor),
            costoLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            margenBadge.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            margenBadge.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            margenBadge.heightAnchor.constraint(equalToConstant: 26),
            
            margenLabel.topAnchor.constraint(equalTo: margenBadge.topAnchor, constant: 4),
            margenLabel.bottomAnchor.constraint(equalTo: margenBadge.bottomAnchor, constant: -4),
            margenLabel.leadingAnchor.constraint(equalTo: margenBadge.leadingAnchor, constant: 10),
            margenLabel.trailingAnchor.constraint(equalTo: margenBadge.trailingAnchor, constant: -10),
            
            fechaLabel.trailingAnchor.constraint(equalTo: margenBadge.leadingAnchor, constant: -12),
            fechaLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with precio: Precio) {
        precioUnitarioLabel.text = precio.precioUnitarioFormateado
        costoLabel.text = "Costo: \(precio.costoFormateado)"
        margenLabel.text = "Margen: \(precio.margenFormateado)"
        
        // Formato fecha
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        fechaLabel.text = formatter.string(from: precio.fechaRegistro)
        
        // Badge activo
        activoBadge.isHidden = !precio.esActivo
        
        // Estilo según estado
        if precio.esActivo {
            containerView.backgroundColor = .systemGreen.withAlphaComponent(0.05)
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.3).cgColor
        } else {
            containerView.backgroundColor = .systemBackground
            containerView.layer.borderWidth = 0.5
            containerView.layer.borderColor = UIColor.separator.cgColor
        }
        
        // Color del margen
        if precio.margen >= 30 {
            margenBadge.backgroundColor = .systemGreen.withAlphaComponent(0.15)
            margenLabel.textColor = .systemGreen
        } else if precio.margen >= 15 {
            margenBadge.backgroundColor = .systemBlue.withAlphaComponent(0.15)
            margenLabel.textColor = .systemBlue
        } else {
            margenBadge.backgroundColor = .systemOrange.withAlphaComponent(0.15)
            margenLabel.textColor = .systemOrange
        }
    }
}
