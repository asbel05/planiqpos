//
//  MarcasViewModel.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import Foundation
import SwiftData

@MainActor
final class MarcasViewModel {
    
    // MARK: - Callbacks
    var onMarcasUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: ((String) -> Void)?
    
    // MARK: - Properties
    private(set) var marcas: [Marca] = []
    private let context: ModelContext
    
    init() {
        self.context = AppDelegate.sharedModelContainer.mainContext
    }
    
    // MARK: - CRUD Operations
    
    func fetchMarcas() {
        let descriptor = FetchDescriptor<Marca>(
            sortBy: [SortDescriptor(\.nombre, order: .forward)]
        )
        
        do {
            marcas = try context.fetch(descriptor)
            onMarcasUpdated?()
        } catch {
            onError?("Error al cargar marcas: \(error.localizedDescription)")
        }
    }
    
    func addMarca(nombre: String) {
        let trimmed = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            onError?("El nombre no puede estar vacío")
            return
        }
        
        // Verificar duplicados
        if marcas.contains(where: { $0.nombre.lowercased() == trimmed.lowercased() }) {
            onError?("Ya existe una marca con ese nombre")
            return
        }
        
        let marca = Marca(nombre: trimmed)
        context.insert(marca)
        
        do {
            try context.save()
            onSuccess?("Marca creada exitosamente")
            fetchMarcas()
        } catch {
            onError?("Error al guardar: \(error.localizedDescription)")
        }
    }
    
    func updateMarca(_ marca: Marca, nombre: String) {
        let trimmed = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            onError?("El nombre no puede estar vacío")
            return
        }
        
        // Verificar duplicados (excluyendo la actual)
        if marcas.contains(where: { $0.id != marca.id && $0.nombre.lowercased() == trimmed.lowercased() }) {
            onError?("Ya existe una marca con ese nombre")
            return
        }
        
        marca.nombre = trimmed
        
        do {
            try context.save()
            onSuccess?("Marca actualizada")
            fetchMarcas()
        } catch {
            onError?("Error al actualizar: \(error.localizedDescription)")
        }
    }
    
    func toggleEstado(_ marca: Marca) {
        marca.estado.toggle()
        
        do {
            try context.save()
            let estado = marca.estado ? "activada" : "desactivada"
            onSuccess?("Marca \(estado)")
            fetchMarcas()
        } catch {
            onError?("Error al cambiar estado: \(error.localizedDescription)")
        }
    }
    
    func deleteMarca(_ marca: Marca) -> Bool {
        // Verificar si tiene productos asociados
        if marca.productosCount > 0 {
            onError?("No se puede eliminar: tiene \(marca.productosCount) productos asociados")
            return false
        }
        
        context.delete(marca)
        
        do {
            try context.save()
            onSuccess?("Marca eliminada")
            fetchMarcas()
            return true
        } catch {
            onError?("Error al eliminar: \(error.localizedDescription)")
            return false
        }
    }
}
