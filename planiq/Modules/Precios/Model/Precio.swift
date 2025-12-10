//
//  Precio.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import Foundation
import SwiftData

@Model
final class Precio {
    @Attribute(.unique) var id: UUID
    var unidadMinima: Int
    var precioUnitario: Double
    var precioMayorista: Double
    var costoNeto: Double
    var costoBase: Double
    var unidadCompra: Int
    var unidadBonificacion: Int
    var descuento1: Double
    var descuento2: Double
    var descuento3: Double
    var esActivo: Bool
    var fechaRegistro: Date
    
    // Relación hacia Producto (lado "muchos")
    var producto: Producto?
    
    // Relación con DetallePedido
    @Relationship(deleteRule: .nullify, inverse: \DetallePedido.precio)
    var detallesPedido: [DetallePedido] = []
    
    init(
        precioUnitario: Double,
        precioMayorista: Double = 0,
        costoNeto: Double = 0,
        costoBase: Double = 0,
        unidadMinima: Int = 1,
        unidadCompra: Int = 1,
        unidadBonificacion: Int = 0,
        descuento1: Double = 0,
        descuento2: Double = 0,
        descuento3: Double = 0,
        esActivo: Bool = true
    ) {
        self.id = UUID()
        self.precioUnitario = precioUnitario
        self.precioMayorista = precioMayorista
        self.costoNeto = costoNeto
        self.costoBase = costoBase
        self.unidadMinima = unidadMinima
        self.unidadCompra = unidadCompra
        self.unidadBonificacion = unidadBonificacion
        self.descuento1 = descuento1
        self.descuento2 = descuento2
        self.descuento3 = descuento3
        self.esActivo = esActivo
        self.fechaRegistro = Date()
    }
    
    // MARK: - Computed Properties
    
    var precioUnitarioFormateado: String {
        String(format: "S/ %.2f", precioUnitario)
    }
    
    var precioMayoristaFormateado: String {
        String(format: "S/ %.2f", precioMayorista)
    }
    
    var costoFormateado: String {
        String(format: "S/ %.2f", costoNeto)
    }
    
    var margen: Double {
        guard precioUnitario > 0 else { return 0 }
        return ((precioUnitario - costoNeto) / precioUnitario) * 100
    }
    
    var margenFormateado: String {
        String(format: "%.1f%%", margen)
    }
    
    var ganancia: Double {
        precioUnitario - costoNeto
    }
    
    var gananciaFormateada: String {
        String(format: "S/ %.2f", ganancia)
    }
    
    var productoNombre: String {
        producto?.descripcion ?? "Sin producto"
    }
    
    var productoCodigo: String {
        producto?.codigo ?? "---"
    }
}
