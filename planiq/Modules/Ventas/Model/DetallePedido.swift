//
//  DetallePedido.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import Foundation
import SwiftData

@Model
final class DetallePedido {
    @Attribute(.unique) var id: UUID
    var cantidad: Int
    var precioUnitario: Double
    var descuento: Double
    var subtotal: Double
    var costo: Double
    
    // Relaciones
    var pedido: Pedido?
    var producto: Producto?
    var precio: Precio?
    
    init(cantidad: Int, precioUnitario: Double, descuento: Double = 0, costo: Double = 0) {
        self.id = UUID()
        self.cantidad = cantidad
        self.precioUnitario = precioUnitario
        self.descuento = descuento
        self.subtotal = (Double(cantidad) * precioUnitario) - descuento
        self.costo = costo
    }
    
    // MARK: - Computed Properties
    
    var productoNombre: String {
        producto?.descripcion ?? "---"
    }
    
    var productoCodigo: String {
        producto?.codigo ?? "---"
    }
    
    var productoUnidad: String {
        producto?.unidadAbreviatura ?? "und"
    }
    
    var precioUnitarioFormateado: String {
        String(format: "S/ %.2f", precioUnitario)
    }
    
    var subtotalFormateado: String {
        String(format: "S/ %.2f", subtotal)
    }
    
    var ganancia: Double {
        subtotal - (costo * Double(cantidad))
    }
    
    var gananciaFormateada: String {
        String(format: "S/ %.2f", ganancia)
    }
    
    // MARK: - Methods
    
    func recalcularSubtotal() {
        subtotal = (Double(cantidad) * precioUnitario) - descuento
    }
}
