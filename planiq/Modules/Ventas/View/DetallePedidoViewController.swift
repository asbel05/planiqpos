//
//  DetallePedidoViewController.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit

final class DetallePedidoViewController: UIViewController {
    
    private let pedido: Pedido
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let headerView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemGreen
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let numeroLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .monospacedSystemFont(ofSize: 18, weight: .bold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let fechaLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14)
        lbl.textColor = .white.withAlphaComponent(0.8)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let totalLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 28, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .right
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let detallesTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    init(pedido: Pedido) {
        self.pedido = pedido
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Detalle de Pedido"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerView)
        headerView.addSubview(numeroLabel)
        headerView.addSubview(fechaLabel)
        headerView.addSubview(totalLabel)
        contentView.addSubview(detallesTableView)
        
        detallesTableView.delegate = self
        detallesTableView.dataSource = self
        
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
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            numeroLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            numeroLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            fechaLabel.topAnchor.constraint(equalTo: numeroLabel.bottomAnchor, constant: 4),
            fechaLabel.leadingAnchor.constraint(equalTo: numeroLabel.leadingAnchor),
            
            totalLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            totalLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            detallesTableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            detallesTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detallesTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detallesTableView.heightAnchor.constraint(equalToConstant: CGFloat(pedido.detalles.count * 60)),
            detallesTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func configureData() {
        numeroLabel.text = pedido.numeroPedido
        fechaLabel.text = pedido.fechaFormateada
        totalLabel.text = pedido.totalFormateado
    }
}

extension DetallePedidoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pedido.detalles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let detalle = pedido.detalles[indexPath.row]
        cell.textLabel?.text = "\(detalle.cantidad)x \(detalle.productoNombre)"
        cell.detailTextLabel?.text = detalle.subtotalFormateado
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 60 }
}
