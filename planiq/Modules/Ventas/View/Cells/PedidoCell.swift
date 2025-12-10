//
//  PedidoCell.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class PedidoCell: UITableViewCell {
    
    static let identifier = "PedidoCell"
    
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
    
    private let estadoIndicator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let numeroPedidoLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 14, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let fechaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let clienteLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .systemGreen
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let metodoPagoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .tertiaryLabel
        label.textAlignment = .right
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
        containerView.addSubview(estadoIndicator)
        containerView.addSubview(numeroPedidoLabel)
        containerView.addSubview(fechaLabel)
        containerView.addSubview(clienteLabel)
        containerView.addSubview(infoLabel)
        containerView.addSubview(totalLabel)
        containerView.addSubview(metodoPagoLabel)
        containerView.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            estadoIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            estadoIndicator.centerYAnchor.constraint(equalTo: numeroPedidoLabel.centerYAnchor),
            estadoIndicator.widthAnchor.constraint(equalToConstant: 10),
            estadoIndicator.heightAnchor.constraint(equalToConstant: 10),
            
            numeroPedidoLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            numeroPedidoLabel.leadingAnchor.constraint(equalTo: estadoIndicator.trailingAnchor, constant: 8),
            
            fechaLabel.centerYAnchor.constraint(equalTo: numeroPedidoLabel.centerYAnchor),
            fechaLabel.leadingAnchor.constraint(equalTo: numeroPedidoLabel.trailingAnchor, constant: 12),
            
            clienteLabel.topAnchor.constraint(equalTo: numeroPedidoLabel.bottomAnchor, constant: 4),
            clienteLabel.leadingAnchor.constraint(equalTo: numeroPedidoLabel.leadingAnchor),
            clienteLabel.trailingAnchor.constraint(equalTo: totalLabel.leadingAnchor, constant: -8),
            
            infoLabel.topAnchor.constraint(equalTo: clienteLabel.bottomAnchor, constant: 2),
            infoLabel.leadingAnchor.constraint(equalTo: numeroPedidoLabel.leadingAnchor),
            infoLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12),
            
            totalLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            totalLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            
            metodoPagoLabel.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 2),
            metodoPagoLabel.trailingAnchor.constraint(equalTo: totalLabel.trailingAnchor),
            
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with pedido: Pedido) {
        numeroPedidoLabel.text = pedido.numeroPedido
        fechaLabel.text = pedido.fechaFormateada
        clienteLabel.text = pedido.clienteNombre
        infoLabel.text = "\(pedido.cantidadItems) items • \(pedido.tipoComprobante.rawValue)"
        totalLabel.text = pedido.totalFormateado
        metodoPagoLabel.text = pedido.metodosPagoUsados
        
        switch pedido.estado {
        case .completado:
            estadoIndicator.backgroundColor = .systemGreen
            totalLabel.textColor = .systemGreen
        case .pendiente:
            estadoIndicator.backgroundColor = .systemOrange
            totalLabel.textColor = .systemOrange
        case .cancelado:
            estadoIndicator.backgroundColor = .systemRed
            totalLabel.textColor = .systemRed
            containerView.alpha = 0.6
        }
    }
}
