//
//  UnidadesViewModel.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import Foundation
import SwiftData

@MainActor
final class UnidadesViewModel {
    
    // MARK: - Callbacks
    var onUnidadesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: ((String) -> Void)?
    
    // MARK: - Properties
    private(set) var unidades: [Unidad] = []
    private let context: ModelContext
    
    init() {
        self.context = AppDelegate.sharedModelContainer.mainContext
    }
    
    // MARK: - CRUD Operations
    
    func fetchUnidades() {
        let descriptor = FetchDescriptor<Unidad>(
            sortBy: [SortDescriptor(\.nombre, order: .forward)]
        )
        
        do {
            unidades = try context.fetch(descriptor)
            onUnidadesUpdated?()
        } catch {
            onError?("Error al cargar unidades: \(error.localizedDescription)")
        }
    }
    
    func addUnidad(nombre: String, abreviatura: String) {
        let trimmedNombre = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAbrev = abreviatura.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard !trimmedNombre.isEmpty else {
            onError?("El nombre no puede estar vacío")
            return
        }
        
        guard !trimmedAbrev.isEmpty else {
            onError?("La abreviatura no puede estar vacía")
            return
        }
        
        // Verificar duplicados por nombre
        if unidades.contains(where: { $0.nombre.lowercased() == trimmedNombre.lowercased() }) {
            onError?("Ya existe una unidad con ese nombre")
            return
        }
        
        // Verificar duplicados por abreviatura
        if unidades.contains(where: { $0.abreviatura.lowercased() == trimmedAbrev }) {
            onError?("Ya existe una unidad con esa abreviatura")
            return
        }
        
        let unidad = Unidad(nombre: trimmedNombre, abreviatura: trimmedAbrev)
        context.insert(unidad)
        
        do {
            try context.save()
            onSuccess?("Unidad creada exitosamente")
            fetchUnidades()
        } catch {
            onError?("Error al guardar: \(error.localizedDescription)")
        }
    }
    
    func updateUnidad(_ unidad: Unidad, nombre: String, abreviatura: String) {
        let trimmedNombre = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAbrev = abreviatura.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard !trimmedNombre.isEmpty else {
            onError?("El nombre no puede estar vacío")
            return
        }
        
        guard !trimmedAbrev.isEmpty else {
            onError?("La abreviatura no puede estar vacía")
            return
        }
        
        // Verificar duplicados (excluyendo la actual)
        if unidades.contains(where: { $0.id != unidad.id && $0.nombre.lowercased() == trimmedNombre.lowercased() }) {
            onError?("Ya existe una unidad con ese nombre")
            return
        }
        
        if unidades.contains(where: { $0.id != unidad.id && $0.abreviatura.lowercased() == trimmedAbrev }) {
            onError?("Ya existe una unidad con esa abreviatura")
            return
        }
        
        unidad.nombre = trimmedNombre
        unidad.abreviatura = trimmedAbrev
        
        do {
            try context.save()
            onSuccess?("Unidad actualizada")
            fetchUnidades()
        } catch {
            onError?("Error al actualizar: \(error.localizedDescription)")
        }
    }
    
    func toggleEstado(_ unidad: Unidad) {
        unidad.estado.toggle()
        
        do {
            try context.save()
            let estado = unidad.estado ? "activada" : "desactivada"
            onSuccess?("Unidad \(estado)")
            fetchUnidades()
        } catch {
            onError?("Error al cambiar estado: \(error.localizedDescription)")
        }
    }
    
    func deleteUnidad(_ unidad: Unidad) -> Bool {
        // Verificar si tiene productos asociados
        if unidad.productosCount > 0 {
            onError?("No se puede eliminar: tiene \(unidad.productosCount) productos asociados")
            return false
        }
        
        context.delete(unidad)
        
        do {
            try context.save()
            onSuccess?("Unidad eliminada")
            fetchUnidades()
            return true
        } catch {
            onError?("Error al eliminar: \(error.localizedDescription)")
            return false
        }
    }
}
