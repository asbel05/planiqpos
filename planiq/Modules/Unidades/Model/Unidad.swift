//
//  Unidad.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import Foundation
import SwiftData

@Model
final class Unidad {
    @Attribute(.unique) var id: UUID
    var nombre: String
    var abreviatura: String
    var estado: Bool
    var fechaRegistro: Date
    
    @Relationship(deleteRule: .nullify, inverse: \Producto.unidad)
    var productos: [Producto] = []
    
    init(nombre: String, abreviatura: String) {
        self.id = UUID()
        self.nombre = nombre
        self.abreviatura = abreviatura
        self.estado = true
        self.fechaRegistro = Date()
    }
    
    var displayName: String { "\(nombre) (\(abreviatura))" }
    var productosCount: Int { productos.count }
    var productosActivos: Int { productos.filter { $0.estado }.count }
}
