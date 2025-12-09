//
//  User.swift
//  planiq
//
//  Created by Asbel on 8/12/25.
//

import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var nombres: String
    var apellidos: String
    var email: String
    var celular: String
    var password: String
    var role: UserRole
    var isActive: Bool
    var createdAt: Date
    
    init(nombres: String, apellidos: String, email: String, celular: String, password: String, role: UserRole) {
        self.id = UUID()
        self.nombres = nombres
        self.apellidos = apellidos
        self.email = email
        self.celular = celular
        self.password = password
        self.role = role
        self.isActive = true
        self.createdAt = Date()
    }
    
    var nombreCompleto: String {
        "\(nombres) \(apellidos)"
    }
}

enum UserRole: String, Codable, CaseIterable {
    case admin = "Administrador"
    case cashier = "Cajero"
}
