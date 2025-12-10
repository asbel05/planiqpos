//
//  Pedido.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import Foundation
import SwiftData

enum EstadoPedido: String, Codable, CaseIterable {
    case pendiente = "Pendiente"
    case completado = "Completado"
    case cancelado = "Cancelado"
    
    var colorName: String {
        switch self {
        case .pendiente: return "systemOrange"
        case .completado: return "systemGreen"
        case .cancelado: return "systemRed"
        }
    }
    
    var emoji: String {
        switch self {
        case .pendiente: return "🟡"
        case .completado: return "🟢"
        case .cancelado: return "🔴"
        }
    }
}

enum TipoComprobante: String, Codable, CaseIterable {
    case boleta = "Boleta"
    case factura = "Factura"
    case ticketSimple = "Ticket"
    
    var prefijoNumeracion: String {
        switch self {
        case .boleta: return "B"
        case .factura: return "F"
        case .ticketSimple: return "T"
        }
    }
    
    var icono: String {
        switch self {
        case .boleta: return "doc.text.fill"
        case .factura: return "doc.richtext.fill"
        case .ticketSimple: return "receipt.fill"
        }
    }
}

@Model
final class Pedido {
    @Attribute(.unique) var id: UUID
    var numeroPedido: String
    var fecha: Date
    var subtotal: Double
    var descuentoTotal: Double
    var igv: Double
    var total: Double
    var costoTotal: Double
    var estado: EstadoPedido
    var tipoComprobante: TipoComprobante
    var nombreCliente: String?
    var observaciones: String?
    
    // Relaciones
    var vendedor: User?
    var cajero: User?
    var cliente: Cliente?
    
    @Relationship(deleteRule: .cascade, inverse: \DetallePedido.pedido)
    var detalles: [DetallePedido] = []
    
    @Relationship(deleteRule: .cascade, inverse: \PagoPedido.pedido)
    var pagos: [PagoPedido] = []
    
    @Relationship(deleteRule: .nullify, inverse: \MovimientoStock.pedido)
    var movimientosStock: [MovimientoStock] = []
    
    init(numeroPedido: String, tipoComprobante: TipoComprobante = .boleta) {
        self.id = UUID()
        self.numeroPedido = numeroPedido
        self.fecha = Date()
        self.subtotal = 0
        self.descuentoTotal = 0
        self.igv = 0
        self.total = 0
        self.costoTotal = 0
        self.estado = .pendiente
        self.tipoComprobante = tipoComprobante
    }
    
    // MARK: - Computed Properties
    
    var totalFormateado: String {
        String(format: "S/ %.2f", total)
    }
    
    var subtotalFormateado: String {
        String(format: "S/ %.2f", subtotal)
    }
    
    var igvFormateado: String {
        String(format: "S/ %.2f", igv)
    }
    
    var cantidadItems: Int {
        detalles.reduce(0) { $0 + $1.cantidad }
    }
    
    var clienteNombre: String {
        cliente?.nombreCompleto ?? nombreCliente ?? "Cliente general"
    }
    
    var vendedorNombre: String {
        vendedor?.nombreCompleto ?? "---"
    }
    
    var cajeroNombre: String {
        cajero?.nombreCompleto ?? "---"
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
    
    var horaFormateada: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: fecha)
    }
    
    var ganancia: Double {
        total - costoTotal
    }
    
    var gananciaFormateada: String {
        String(format: "S/ %.2f", ganancia)
    }
    
    var metodosPagoUsados: String {
        let tipos = Set(pagos.map { $0.tipoPago.rawValue })
        return tipos.joined(separator: ", ")
    }
    
    // MARK: - Methods
    
    func recalcularTotales() {
        let totalDetalles = detalles.reduce(0.0) { $0 + $1.subtotal }
        costoTotal = detalles.reduce(0.0) { $0 + ($1.costo * Double($1.cantidad)) }
        let totalConDescuento = totalDetalles - descuentoTotal
        // El total ya incluye IGV, así que calculamos el subtotal base
        subtotal = totalConDescuento / 1.18
        igv = totalConDescuento - subtotal
        total = totalConDescuento
    }
    
    static func generarNumero(tipo: TipoComprobante, secuencia: Int) -> String {
        "\(tipo.prefijoNumeracion)001-\(String(format: "%07d", secuencia))"
    }
}
