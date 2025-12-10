//
//  PagoPedido.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import Foundation
import SwiftData

enum TipoPago: String, Codable, CaseIterable {
    case efectivo = "Efectivo"
    case tarjeta = "Tarjeta"
    case yape = "Yape"
    case plin = "Plin"
    case transferencia = "Transferencia"
    
    var icono: String {
        switch self {
        case .efectivo: return "banknote.fill"
        case .tarjeta: return "creditcard.fill"
        case .yape: return "iphone"
        case .plin: return "iphone.gen2"
        case .transferencia: return "arrow.left.arrow.right"
        }
    }
    
    var colorName: String {
        switch self {
        case .efectivo: return "systemGreen"
        case .tarjeta: return "systemBlue"
        case .yape: return "systemPurple"
        case .plin: return "systemTeal"
        case .transferencia: return "systemOrange"
        }
    }
}

@Model
final class PagoPedido {
    @Attribute(.unique) var id: UUID
    var tipoPago: TipoPago
    var monto: Double
    var referencia: String?
    var fecha: Date
    
    // Relación
    var pedido: Pedido?
    
    init(tipoPago: TipoPago, monto: Double, referencia: String? = nil) {
        self.id = UUID()
        self.tipoPago = tipoPago
        self.monto = monto
        self.referencia = referencia
        self.fecha = Date()
    }
    
    // MARK: - Computed Properties
    
    var montoFormateado: String {
        String(format: "S/ %.2f", monto)
    }
    
    var fechaFormateada: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: fecha)
    }
}
