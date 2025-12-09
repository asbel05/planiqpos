//
//  LoginViewModel.swift
//  planiq
//
//  Created by Asbel on 8/12/25.
//

import Foundation
import SwiftData

@MainActor
final class LoginViewModel {
    
    private let modelContext: ModelContext
    
    // MARK: - Inputs (desde la Vista)
    var email: String = "" {
        didSet { validateForm() }
    }
    
    var password: String = "" {
        didSet { validateForm() }
    }
    
    // MARK: - Outputs (hacia la Vista)
    var onFormValidChange: ((Bool) -> Void)?
    var onLoadingChange: ((Bool) -> Void)?
    var onErrorMessage: ((String) -> Void)?
    var onLoginSuccess: ((User) -> Void)?
    var onPasswordResetSuccess: (() -> Void)?
    
    
    // MARK: - Init
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    
    // MARK: - Public API
    func loginWithEmail() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedEmail.isEmpty else {
            onErrorMessage?("Ingresa tu correo electrónico.")
            return
        }
        
        guard isValidEmail(trimmedEmail) else {
            onErrorMessage?("El formato del correo es inválido.")
            return
        }
        
        guard password.count >= 6 else {
            onErrorMessage?("La contraseña debe tener al menos 6 caracteres.")
            return
        }
        
        onLoadingChange?(true)
        
        // Buscar usuario en SwiftData
        Task {
            let fetchDescriptor = FetchDescriptor<User>(
                predicate: #Predicate { user in
                    user.email == trimmedEmail
                }
            )
            
            do {
                let users = try modelContext.fetch(fetchDescriptor)
                
                onLoadingChange?(false)
                
                guard let user = users.first else {
                    onErrorMessage?("Usuario no encontrado.")
                    return
                }
                
                guard user.password == password else {
                    onErrorMessage?("Contraseña incorrecta.")
                    return
                }
                
                onLoginSuccess?(user)
            } catch {
                onLoadingChange?(false)
                onErrorMessage?("Error al iniciar sesión: \(error.localizedDescription)")
            }
        }
    }
    
    func resetPassword(email: String) {
        Task {
            let fetchDescriptor = FetchDescriptor<User>(
                predicate: #Predicate { user in
                    user.email == email
                }
            )
            
            do {
                let users = try modelContext.fetch(fetchDescriptor)
                
                guard let user = users.first else {
                    onErrorMessage?("No se encontró un usuario con ese correo.")
                    return
                }
                
                user.password = "admin123"
                try modelContext.save()
                
                onPasswordResetSuccess?()
                
            } catch {
                onErrorMessage?("Error al restablecer contraseña: \(error.localizedDescription)")
            }
        }
    }
    
    
    // MARK: - Private
    private func validateForm() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let isValid = !trimmedEmail.isEmpty && !password.isEmpty
        onFormValidChange?(isValid)
    }
    
    private func isValidEmail(_ value: String) -> Bool {
        let pattern = #"^\S+@\S+\.\S+$"#
        return value.range(of: pattern, options: .regularExpression) != nil
    }
}
