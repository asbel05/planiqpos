//
//  CarritoItemCell.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class CarritoItemCell: UITableViewCell {
    
    static let identifier = "CarritoItemCell"
    
    // MARK: - Callbacks
    var onIncrementar: (() -> Void)?
    var onDecrementar: (() -> Void)?
    var onEliminar: (() -> Void)?
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nombreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let precioUnitarioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let decrementButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        btn.tintColor = .systemGray
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let cantidadLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let incrementButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        btn.tintColor = .systemGreen
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let subtotalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .systemGreen
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let eliminarButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        btn.tintColor = .systemRed
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
        onIncrementar = nil
        onDecrementar = nil
        onEliminar = nil
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(nombreLabel)
        containerView.addSubview(precioUnitarioLabel)
        containerView.addSubview(decrementButton)
        containerView.addSubview(cantidadLabel)
        containerView.addSubview(incrementButton)
        containerView.addSubview(subtotalLabel)
        containerView.addSubview(eliminarButton)
        
        decrementButton.addTarget(self, action: #selector(decrementTapped), for: .touchUpInside)
        incrementButton.addTarget(self, action: #selector(incrementTapped), for: .touchUpInside)
        eliminarButton.addTarget(self, action: #selector(eliminarTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            nombreLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            nombreLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            nombreLabel.trailingAnchor.constraint(equalTo: eliminarButton.leadingAnchor, constant: -8),
            
            precioUnitarioLabel.topAnchor.constraint(equalTo: nombreLabel.bottomAnchor, constant: 2),
            precioUnitarioLabel.leadingAnchor.constraint(equalTo: nombreLabel.leadingAnchor),
            
            decrementButton.topAnchor.constraint(equalTo: precioUnitarioLabel.bottomAnchor, constant: 6),
            decrementButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            decrementButton.widthAnchor.constraint(equalToConstant: 28),
            decrementButton.heightAnchor.constraint(equalToConstant: 28),
            decrementButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            cantidadLabel.centerYAnchor.constraint(equalTo: decrementButton.centerYAnchor),
            cantidadLabel.leadingAnchor.constraint(equalTo: decrementButton.trailingAnchor, constant: 8),
            cantidadLabel.widthAnchor.constraint(equalToConstant: 40),
            
            incrementButton.centerYAnchor.constraint(equalTo: decrementButton.centerYAnchor),
            incrementButton.leadingAnchor.constraint(equalTo: cantidadLabel.trailingAnchor, constant: 8),
            incrementButton.widthAnchor.constraint(equalToConstant: 28),
            incrementButton.heightAnchor.constraint(equalToConstant: 28),
            
            subtotalLabel.centerYAnchor.constraint(equalTo: decrementButton.centerYAnchor),
            subtotalLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            subtotalLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),
            
            eliminarButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            eliminarButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            eliminarButton.widthAnchor.constraint(equalToConstant: 24),
            eliminarButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    @objc private func decrementTapped() { onDecrementar?() }
    @objc private func incrementTapped() { onIncrementar?() }
    @objc private func eliminarTapped() { onEliminar?() }
    
    // MARK: - Configure
    
    func configure(with item: CarritoItem) {
        nombreLabel.text = item.producto.descripcion
        precioUnitarioLabel.text = item.precio.precioUnitarioFormateado
        cantidadLabel.text = "\(item.cantidad)"
        subtotalLabel.text = item.subtotalFormateado
    }
}
