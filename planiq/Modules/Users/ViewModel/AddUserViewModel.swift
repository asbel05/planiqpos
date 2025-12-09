//
//  AddUserViewModel.swift
//  planiq
//
//  Created by Asbel on 8/12/25.
//

import Foundation
import SwiftData

@MainActor
final class AddUserViewModel {
    
    private let modelContext: ModelContext
    
    // MARK: - Inputs
    var nombres: String = "" {
        didSet { validateForm() }
    }
    
    var apellidos: String = "" {
        didSet { validateForm() }
    }
    
    var email: String = "" {
        didSet { validateForm() }
    }
    
    var celular: String = "" {
        didSet { validateForm() }
    }
    
    var password: String = "" {
        didSet { validateForm() }
    }
    
    var confirmPassword: String = "" {
        didSet { validateForm() }
    }
    
    var role: UserRole = .cashier
    
    // MARK: - Outputs
    var onFormValidChange: ((Bool) -> Void)?
    var onLoadingChange: ((Bool) -> Void)?
    var onErrorMessage: ((String) -> Void)?
    var onUserCreated: (() -> Void)?
    
    // MARK: - Init
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Public API
    func createUser() {
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
        
        guard password.count >= 6 else {
            onErrorMessage?("La contraseña debe tener al menos 6 caracteres.")
            return
        }
        
        guard password == confirmPassword else {
            onErrorMessage?("Las contraseñas no coinciden.")
            return
        }
        
        onLoadingChange?(true)
        
        Task {
            // Verificar si el email ya existe
            let fetchDescriptor = FetchDescriptor<User>(
                predicate: #Predicate { user in
                    user.email == trimmedEmail
                }
            )
            
            do {
                let existingUsers = try modelContext.fetch(fetchDescriptor)
                
                guard existingUsers.isEmpty else {
                    onLoadingChange?(false)
                    onErrorMessage?("Este correo ya está registrado.")
                    return
                }
                
                let newUser = User(
                    nombres: trimmedNombres,
                    apellidos: trimmedApellidos,
                    email: trimmedEmail,
                    celular: trimmedCelular,
                    password: password,
                    role: role
                )
                
                modelContext.insert(newUser)
                try modelContext.save()
                
                onLoadingChange?(false)
                onUserCreated?()
                
            } catch {
                onLoadingChange?(false)
                onErrorMessage?("Error al crear usuario: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private
    private func validateForm() {
        let trimmedNombres = nombres.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedApellidos = apellidos.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCelular = celular.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let isValid = !trimmedNombres.isEmpty &&
                      !trimmedApellidos.isEmpty &&
                      !trimmedEmail.isEmpty &&
                      !trimmedCelular.isEmpty &&
                      !password.isEmpty &&
                      !confirmPassword.isEmpty
        
        onFormValidChange?(isValid)
    }
    
    private func isValidEmail(_ value: String) -> Bool {
        let pattern = #"^\S+@\S+\.\S+$"#
        return value.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func isValidPhone(_ value: String) -> Bool {
        let digits = value.filter { $0.isNumber }
        return digits.count == 9
    }
}
