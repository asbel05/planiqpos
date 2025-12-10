//
//  User.swift
//  planiq
//
//  Created by Asbel on 8/12/25.
//

import Foundation
import SwiftData

enum UserRole: String, Codable, CaseIterable {
    case admin = "admin"
    case vendedor = "vendedor"
    case cashier = "cashier"
    
    var displayName: String {
        switch self {
        case .admin: return "Administrador"
        case .vendedor: return "Vendedor"
        case .cashier: return "Cajero"
        }
    }
    
    // Permisos
    var canSell: Bool { self == .admin || self == .vendedor }
    var canCharge: Bool { true }
    var canManageStock: Bool { self == .admin || self == .vendedor }
    var canManageUsers: Bool { self == .admin }
    var canManageProducts: Bool { self == .admin }
    var canViewReports: Bool { self == .admin }
}

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var nombres: String
    var apellidos: String
    @Attribute(.unique) var email: String
    var celular: String
    var password: String
    var role: UserRole
    var isActive: Bool
    var fechaRegistro: Date
    
    init(nombres: String, apellidos: String, email: String, celular: String, password: String, role: UserRole) {
        self.id = UUID()
        self.nombres = nombres
        self.apellidos = apellidos
        self.email = email
        self.celular = celular
        self.password = password
        self.role = role
        self.isActive = true
        self.fechaRegistro = Date()
    }
    
    var nombreCompleto: String {
        "\(nombres) \(apellidos)"
    }
    
    var iniciales: String {
        "\(nombres.prefix(1))\(apellidos.prefix(1))".uppercased()
    }
    
    // Alias para compatibilidad
    var createdAt: Date {
        fechaRegistro
    }
}
