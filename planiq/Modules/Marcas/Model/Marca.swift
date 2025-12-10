//
//  Marca.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import Foundation
import SwiftData

@Model
final class Marca {
    @Attribute(.unique) var id: UUID
    var nombre: String
    var estado: Bool
    var fechaRegistro: Date
    
    @Relationship(deleteRule: .nullify, inverse: \Producto.marca)
    var productos: [Producto] = []
    
    init(nombre: String) {
        self.id = UUID()
        self.nombre = nombre
        self.estado = true
        self.fechaRegistro = Date()
    }
    
    var productosCount: Int { productos.count }
    var productosActivos: Int { productos.filter { $0.estado }.count }
}
