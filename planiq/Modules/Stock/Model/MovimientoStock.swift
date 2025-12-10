//
//  MovimientoStock.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import Foundation
import SwiftData

enum TipoMovimiento: String, Codable, CaseIterable {
    case entrada = "Entrada"
    case salida = "Salida"
    case ajuste = "Ajuste"
    case devolucion = "Devolución"
    case venta = "Venta"
    
    var icono: String {
        switch self {
        case .entrada: return "arrow.down.circle.fill"
        case .salida: return "arrow.up.circle.fill"
        case .ajuste: return "arrow.left.arrow.right.circle.fill"
        case .devolucion: return "arrow.uturn.backward.circle.fill"
        case .venta: return "cart.fill"
        }
    }
    
    var colorName: String {
        switch self {
        case .entrada, .devolucion: return "systemGreen"
        case .salida, .venta: return "systemRed"
        case .ajuste: return "systemBlue"
        }
    }
    
    var signo: String {
        switch self {
        case .entrada, .devolucion: return "+"
        case .salida, .venta: return "-"
        case .ajuste: return "="
        }
    }
}

@Model
final class MovimientoStock {
    @Attribute(.unique) var id: UUID
    var tipo: TipoMovimiento
    var cantidad: Int
    var cantidadAnterior: Int
    var cantidadNueva: Int
    var motivo: String?
    var fecha: Date
    
    // Relaciones
    var stock: Stock?
    var usuario: User?
    var pedido: Pedido?
    
    init(tipo: TipoMovimiento, cantidad: Int, cantidadAnterior: Int, motivo: String? = nil) {
        self.id = UUID()
        self.tipo = tipo
        self.cantidad = cantidad
        self.cantidadAnterior = cantidadAnterior
        self.cantidadNueva = MovimientoStock.calcularNueva(tipo: tipo, anterior: cantidadAnterior, cantidad: cantidad)
        self.motivo = motivo
        self.fecha = Date()
    }
    
    private static func calcularNueva(tipo: TipoMovimiento, anterior: Int, cantidad: Int) -> Int {
        switch tipo {
        case .entrada, .devolucion:
            return anterior + cantidad
        case .salida, .venta:
            return max(0, anterior - cantidad)
        case .ajuste:
            return cantidad
        }
    }
    
    // MARK: - Computed Properties
    
    var usuarioNombre: String {
        usuario?.nombreCompleto ?? "Sistema"
    }
    
    var fechaFormateada: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: fecha)
    }
    
    var fechaCorta: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: fecha)
    }
    
    var cantidadConSigno: String {
        switch tipo {
        case .entrada, .devolucion:
            return "+\(cantidad)"
        case .salida, .venta:
            return "-\(cantidad)"
        case .ajuste:
            return "=\(cantidad)"
        }
    }
    
    var cambioFormateado: String {
        "\(cantidadAnterior) → \(cantidadNueva)"
    }
}
