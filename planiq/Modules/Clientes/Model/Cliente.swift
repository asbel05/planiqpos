//
//  Cliente.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import Foundation
import SwiftData

enum TipoDocumento: String, Codable, CaseIterable {
    case dni = "DNI"
    case ruc = "RUC"
    case ce = "CE"
    case pasaporte = "Pasaporte"
    
    var maxLength: Int {
        switch self {
        case .dni: return 8
        case .ruc: return 11
        case .ce: return 12
        case .pasaporte: return 12
        }
    }
}

@Model
final class Cliente {
    @Attribute(.unique) var id: UUID
    var nombres: String
    var apellidos: String?
    var tipoDocumento: TipoDocumento
    var numeroDocumento: String
    var telefono: String?
    var email: String?
    var direccion: String?
    var estado: Bool
    var fechaRegistro: Date
    
    // Relación con Pedidos
    @Relationship(deleteRule: .nullify, inverse: \Pedido.cliente)
    var pedidos: [Pedido] = []
    
    init(nombres: String, apellidos: String? = nil, tipoDocumento: TipoDocumento, numeroDocumento: String) {
        self.id = UUID()
        self.nombres = nombres
        self.apellidos = apellidos
        self.tipoDocumento = tipoDocumento
        self.numeroDocumento = numeroDocumento
        self.estado = true
        self.fechaRegistro = Date()
    }
    
    // MARK: - Computed Properties
    
    var nombreCompleto: String {
        if let a = apellidos, !a.isEmpty {
            return "\(nombres) \(a)"
        }
        return nombres
    }
    
    var documentoCompleto: String {
        "\(tipoDocumento.rawValue): \(numeroDocumento)"
    }
    
    var iniciales: String {
        let n = nombres.prefix(1).uppercased()
        let a = apellidos?.prefix(1).uppercased() ?? ""
        return "\(n)\(a)"
    }
    
    var pedidosCount: Int {
        pedidos.count
    }
    
    var totalCompras: Double {
        pedidos.filter { $0.estado == .completado }.reduce(0) { $0 + $1.total }
    }
    
    var totalComprasFormateado: String {
        String(format: "S/ %.2f", totalCompras)
    }
}
