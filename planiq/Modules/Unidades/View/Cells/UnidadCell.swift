//
//  UnidadCell.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class UnidadCell: UITableViewCell {
    
    static let identifier = "UnidadCell"
    
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
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemTeal.withAlphaComponent(0.15)
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "scalemass.fill")
        iv.tintColor = .systemTeal
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nombreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let productosCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let abreviaturaBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let abreviaturaLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
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
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        containerView.addSubview(nombreLabel)
        containerView.addSubview(productosCountLabel)
        containerView.addSubview(abreviaturaBadge)
        abreviaturaBadge.addSubview(abreviaturaLabel)
        containerView.addSubview(estadoBadge)
        estadoBadge.addSubview(estadoLabel)
        containerView.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            iconContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            nombreLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nombreLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            
            abreviaturaBadge.centerYAnchor.constraint(equalTo: nombreLabel.centerYAnchor),
            abreviaturaBadge.leadingAnchor.constraint(equalTo: nombreLabel.trailingAnchor, constant: 8),
            abreviaturaBadge.heightAnchor.constraint(equalToConstant: 22),
            
            abreviaturaLabel.topAnchor.constraint(equalTo: abreviaturaBadge.topAnchor, constant: 3),
            abreviaturaLabel.bottomAnchor.constraint(equalTo: abreviaturaBadge.bottomAnchor, constant: -3),
            abreviaturaLabel.leadingAnchor.constraint(equalTo: abreviaturaBadge.leadingAnchor, constant: 8),
            abreviaturaLabel.trailingAnchor.constraint(equalTo: abreviaturaBadge.trailingAnchor, constant: -8),
            
            productosCountLabel.topAnchor.constraint(equalTo: nombreLabel.bottomAnchor, constant: 2),
            productosCountLabel.leadingAnchor.constraint(equalTo: nombreLabel.leadingAnchor),
            productosCountLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            estadoBadge.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            estadoBadge.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            estadoBadge.heightAnchor.constraint(equalToConstant: 20),
            
            estadoLabel.topAnchor.constraint(equalTo: estadoBadge.topAnchor, constant: 3),
            estadoLabel.bottomAnchor.constraint(equalTo: estadoBadge.bottomAnchor, constant: -3),
            estadoLabel.leadingAnchor.constraint(equalTo: estadoBadge.leadingAnchor, constant: 8),
            estadoLabel.trailingAnchor.constraint(equalTo: estadoBadge.trailingAnchor, constant: -8),
            
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with unidad: Unidad) {
        nombreLabel.text = unidad.nombre
        abreviaturaLabel.text = unidad.abreviatura.uppercased()
        productosCountLabel.text = "\(unidad.productosCount) productos"
        
        if unidad.estado {
            estadoBadge.backgroundColor = .systemGreen
            estadoLabel.text = "ACTIVO"
        } else {
            estadoBadge.backgroundColor = .systemRed
            estadoLabel.text = "INACTIVO"
        }
    }
}
