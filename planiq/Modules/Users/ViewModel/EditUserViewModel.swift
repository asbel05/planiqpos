//
//  EditUserViewModel.swift
//  planiq
//
//  Created by Asbel on 8/12/25.
//

import Foundation
import SwiftData

@MainActor
final class EditUserViewModel {
    
    private let modelContext: ModelContext
    private let user: User
    
    // MARK: - Inputs
    var nombres: String = ""
    var apellidos: String = ""
    var email: String = ""
    var celular: String = ""
    var role: UserRole = .cashier
    var isActive: Bool = true
    
    // MARK: - Outputs
    var onLoadingChange: ((Bool) -> Void)?
    var onErrorMessage: ((String) -> Void)?
    var onUserUpdated: (() -> Void)?
    var onPasswordReset: (() -> Void)?
    
    // MARK: - Init
    init(user: User, modelContext: ModelContext) {
        self.user = user
        self.modelContext = modelContext
    }
    
    // MARK: - Public API
    func updateUser() {
        let trimmedNombres = nombres.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedApellidos = apellidos.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCelular = celular.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedNombres.isEmpty else {
            onErrorMessage?("Ingresa los nombres.")
            return
        }
        
        guard !trimmedApellidos.isEmpty else {
            onErrorMessage?("Ingresa los apellidos.")
            return
        }
        
        guard !trimmedEmail.isEmpty else {
            onErrorMessage?("Ingresa el correo electrónico.")
            return
        }
        
        guard isValidEmail(trimmedEmail) else {
            onErrorMessage?("El formato del correo es inválido.")
            return
        }
        
        guard !trimmedCelular.isEmpty else {
            onErrorMessage?("Ingresa el número de celular.")
            return
        }
        
        guard isValidPhone(trimmedCelular) else {
            onErrorMessage?("El número de celular debe tener 9 dígitos.")
            return
        }
        
        onLoadingChange?(true)
        
        Task {
            // Verificar si el email ya existe (excepto el usuario actual)
            if trimmedEmail != user.email {
                let fetchDescriptor = FetchDescriptor<User>(
                    predicate: #Predicate { u in
                        u.email == trimmedEmail
                    }
                )
                
                do {
                    let existingUsers = try modelContext.fetch(fetchDescriptor)
                    
                    if !existingUsers.isEmpty {
                        onLoadingChange?(false)
                        onErrorMessage?("Este correo ya está registrado.")
                        return
                    }
                } catch {
                    onLoadingChange?(false)
                    onErrorMessage?("Error al verificar correo: \(error.localizedDescription)")
                    return
                }
            }
            
            do {
                user.nombres = trimmedNombres
                user.apellidos = trimmedApellidos
                user.email = trimmedEmail
                user.celular = trimmedCelular
                user.role = role
                user.isActive = isActive
                
                try modelContext.save()
                
                onLoadingChange?(false)
                onUserUpdated?()
                
            } catch {
                onLoadingChange?(false)
                onErrorMessage?("Error al actualizar usuario: \(error.localizedDescription)")
            }
        }
    }
    
    func resetPassword() {
        Task {
            do {
                user.password = "admin123"
                try modelContext.save()
                onPasswordReset?()
            } catch {
                onErrorMessage?("Error al restablecer contraseña: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private
    private func isValidEmail(_ value: String) -> Bool {
        let pattern = #"^\S+@\S+\.\S+$"#
        return value.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func isValidPhone(_ value: String) -> Bool {
        let digits = value.filter { $0.isNumber }
        return digits.count == 9
    }
}
