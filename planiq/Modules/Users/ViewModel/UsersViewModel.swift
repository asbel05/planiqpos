//
//  UsersViewModel.swift
//  planiq
//
//  Created by Asbel on 8/12/25.
//

import Foundation
import SwiftData

@MainActor
final class UsersViewModel {
    
    private let modelContext: ModelContext
    
    // MARK: - Data
    var users: [User] = []
    
    // MARK: - Outputs
    var onUsersLoaded: (() -> Void)?
    var onErrorMessage: ((String) -> Void)?
    var onUserDeleted: (() -> Void)?
    
    // MARK: - Init
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Public API
    func loadUsers() {
        Task {
            let fetchDescriptor = FetchDescriptor<User>(
                sortBy: [SortDescriptor(\.fechaRegistro, order: .reverse)]
            )
            
            do {
                users = try modelContext.fetch(fetchDescriptor)
                onUsersLoaded?()
            } catch {
                onErrorMessage?("Error al cargar usuarios: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteUser(_ user: User) {
        Task {
            do {
                modelContext.delete(user)
                try modelContext.save()
                onUserDeleted?()
            } catch {
                onErrorMessage?("Error al eliminar usuario: \(error.localizedDescription)")
            }
        }
    }
}
