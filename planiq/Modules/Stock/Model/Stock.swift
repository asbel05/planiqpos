//
//  Stock.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import Foundation
import SwiftData

enum EstadoStock: String, Codable {
    case sinStock = "Sin Stock"
    case bajo = "Stock Bajo"
    case normal = "Normal"
    case alto = "Stock Alto"
    
    var colorName: String {
        switch self {
        case .sinStock: return "systemRed"
        case .bajo: return "systemOrange"
        case .normal: return "systemGreen"
        case .alto: return "systemBlue"
        }
    }
    
    var emoji: String {
        switch self {
        case .sinStock: return "🔴"
        case .bajo: return "🟠"
        case .normal: return "🟢"
        case .alto: return "🔵"
        }
    }
}

@Model
final class Stock {
    @Attribute(.unique) var id: UUID
    var cantidad: Int
    var stockMinimo: Int
    var stockMaximo: Int?
    var ultimaActualizacion: Date
    
    // Relación hacia Producto
    var producto: Producto?
    
    // Relación con MovimientosStock
    @Relationship(deleteRule: .cascade, inverse: \MovimientoStock.stock)
    var movimientos: [MovimientoStock] = []
    
    init(cantidad: Int = 0, stockMinimo: Int = 5, stockMaximo: Int? = nil) {
        self.id = UUID()
        self.cantidad = cantidad
        self.stockMinimo = stockMinimo
        self.stockMaximo = stockMaximo
        self.ultimaActualizacion = Date()
    }
    
    // MARK: - Computed Properties
    
    var estadoStock: EstadoStock {
        if cantidad <= 0 { return .sinStock }
        if cantidad <= stockMinimo { return .bajo }
        if let max = stockMaximo, cantidad >= max { return .alto }
        return .normal
    }
    
    var productoNombre: String {
        producto?.descripcion ?? "Sin producto"
    }
    
    var productoCodigo: String {
        producto?.codigo ?? "---"
    }
    
    var productoUnidad: String {
        producto?.unidadAbreviatura ?? "und"
    }
    
    var cantidadFormateada: String {
        "\(cantidad) \(productoUnidad)"
    }
}
