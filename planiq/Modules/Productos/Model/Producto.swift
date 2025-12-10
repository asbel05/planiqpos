//
//  Producto.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import Foundation
import SwiftData

@Model
final class Producto {
    @Attribute(.unique) var id: UUID
    var codigo: String
    var descripcion: String
    var estado: Bool
    var imagen: Data?
    var fechaRegistro: Date
    
    // Relaciones opcionales (muchos a uno) - sin inverse aquí
    var categoria: Categoria?
    var marca: Marca?
    var unidad: Unidad?
    
    // Relación uno a muchos con Precio - inverse definida aquí
    @Relationship(deleteRule: .cascade, inverse: \Precio.producto)
    var precios: [Precio] = []
    
    init(codigo: String, descripcion: String, categoria: Categoria? = nil, marca: Marca? = nil, unidad: Unidad? = nil) {
        self.id = UUID()
        self.codigo = codigo
        self.descripcion = descripcion
        self.estado = true
        self.fechaRegistro = Date()
        self.categoria = categoria
        self.marca = marca
        self.unidad = unidad
    }
    
    // MARK: - Computed Properties
    
    var precioActivo: Precio? {
        precios.first { $0.esActivo }
    }
    
    var precioActivoFormateado: String {
        guard let precio = precioActivo else { return "Sin precio" }
        return precio.precioUnitarioFormateado
    }
    
    var categoriaNombre: String {
        categoria?.nombre ?? "Sin categoría"
    }
    
    var marcaNombre: String {
        marca?.nombre ?? "Sin marca"
    }
    
    var unidadNombre: String {
        unidad?.displayName ?? "Sin unidad"
    }
    
    var unidadAbreviatura: String {
        unidad?.abreviatura ?? "und"
    }
    
    // MARK: - Código Auto-generado
    
    static func generarCodigo(secuencia: Int) -> String {
        return "PROD-\(String(format: "%03d", secuencia))"
    }
}
