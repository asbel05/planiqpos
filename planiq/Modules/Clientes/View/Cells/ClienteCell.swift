//
//  ClienteCell.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class ClienteCell: UITableViewCell {
    
    static let identifier = "ClienteCell"
    
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
    
    private let avatarView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 22
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let inicialesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nombreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let documentoLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let telefonoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
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
        containerView.addSubview(avatarView)
        avatarView.addSubview(inicialesLabel)
        containerView.addSubview(nombreLabel)
        containerView.addSubview(documentoLabel)
        containerView.addSubview(telefonoLabel)
        containerView.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            avatarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            avatarView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 44),
            avatarView.heightAnchor.constraint(equalToConstant: 44),
            
            inicialesLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            inicialesLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            nombreLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nombreLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nombreLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            
            documentoLabel.topAnchor.constraint(equalTo: nombreLabel.bottomAnchor, constant: 2),
            documentoLabel.leadingAnchor.constraint(equalTo: nombreLabel.leadingAnchor),
            
            telefonoLabel.topAnchor.constraint(equalTo: documentoLabel.bottomAnchor, constant: 2),
            telefonoLabel.leadingAnchor.constraint(equalTo: nombreLabel.leadingAnchor),
            telefonoLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12),
            
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with cliente: Cliente) {
        inicialesLabel.text = cliente.iniciales
        nombreLabel.text = cliente.nombreCompleto
        documentoLabel.text = cliente.documentoCompleto
        telefonoLabel.text = cliente.telefono ?? "Sin teléfono"
        
        // Color aleatorio pero consistente basado en el nombre
        let colors: [UIColor] = [.systemBlue, .systemPurple, .systemTeal, .systemIndigo, .systemPink]
        let colorIndex = abs(cliente.nombreCompleto.hashValue) % colors.count
        avatarView.backgroundColor = colors[colorIndex]
    }
}
