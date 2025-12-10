//
//  CategoriasViewModel.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import Foundation
import SwiftData

@MainActor
final class CategoriasViewModel {
    
    // MARK: - Callbacks
    var onCategoriasUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: ((String) -> Void)?
    
    // MARK: - Properties
    private(set) var categorias: [Categoria] = []
    private let context: ModelContext
    
    init() {
        self.context = AppDelegate.sharedModelContainer.mainContext
    }
    
    // MARK: - CRUD Operations
    
    func fetchCategorias() {
        let descriptor = FetchDescriptor<Categoria>(
            sortBy: [SortDescriptor(\.nombre, order: .forward)]
        )
        
        do {
            categorias = try context.fetch(descriptor)
            onCategoriasUpdated?()
        } catch {
            onError?("Error al cargar categorías: \(error.localizedDescription)")
        }
    }
    
    func addCategoria(nombre: String) {
        let trimmed = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            onError?("El nombre no puede estar vacío")
            return
        }
        
        // Verificar duplicados
        if categorias.contains(where: { $0.nombre.lowercased() == trimmed.lowercased() }) {
            onError?("Ya existe una categoría con ese nombre")
            return
        }
        
        let categoria = Categoria(nombre: trimmed)
        context.insert(categoria)
        
        do {
            try context.save()
            onSuccess?("Categoría creada exitosamente")
            fetchCategorias()
        } catch {
            onError?("Error al guardar: \(error.localizedDescription)")
        }
    }
    
    func updateCategoria(_ categoria: Categoria, nombre: String) {
        let trimmed = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            onError?("El nombre no puede estar vacío")
            return
        }
        
        // Verificar duplicados (excluyendo la actual)
        if categorias.contains(where: { $0.id != categoria.id && $0.nombre.lowercased() == trimmed.lowercased() }) {
            onError?("Ya existe una categoría con ese nombre")
            return
        }
        
        categoria.nombre = trimmed
        
        do {
            try context.save()
            onSuccess?("Categoría actualizada")
            fetchCategorias()
        } catch {
            onError?("Error al actualizar: \(error.localizedDescription)")
        }
    }
    
    func toggleEstado(_ categoria: Categoria) {
        categoria.estado.toggle()
        
        do {
            try context.save()
            let estado = categoria.estado ? "activada" : "desactivada"
            onSuccess?("Categoría \(estado)")
            fetchCategorias()
        } catch {
            onError?("Error al cambiar estado: \(error.localizedDescription)")
        }
    }
    
    func deleteCategoria(_ categoria: Categoria) -> Bool {
        // Verificar si tiene productos asociados
        if categoria.productosCount > 0 {
            onError?("No se puede eliminar: tiene \(categoria.productosCount) productos asociados")
            return false
        }
        
        context.delete(categoria)
        
        do {
            try context.save()
            onSuccess?("Categoría eliminada")
            fetchCategorias()
            return true
        } catch {
            onError?("Error al eliminar: \(error.localizedDescription)")
            return false
        }
    }
}
