//
//  ProductosViewModel.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import Foundation
import SwiftData

enum FiltroProducto: Int, CaseIterable {
    case todos = 0
    case activos = 1
    case inactivos = 2
    
    var titulo: String {
        switch self {
        case .todos: return "Todos"
        case .activos: return "Activos"
        case .inactivos: return "Inactivos"
        }
    }
}

@MainActor
final class ProductosViewModel {
    
    // MARK: - Callbacks
    var onProductosUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: ((String) -> Void)?
    
    // MARK: - Properties
    private(set) var productos: [Producto] = []
    private(set) var productosFiltrados: [Producto] = []
    private let context: ModelContext
    
    var filtroActual: FiltroProducto = .todos
    var busqueda: String = ""
    
    init() {
        self.context = AppDelegate.sharedModelContainer.mainContext
    }
    
    // MARK: - Fetch
    
    func fetchProductos() {
        let descriptor = FetchDescriptor<Producto>(
            sortBy: [SortDescriptor(\.descripcion, order: .forward)]
        )
        
        do {
            productos = try context.fetch(descriptor)
            aplicarFiltros()
        } catch {
            onError?("Error al cargar productos: \(error.localizedDescription)")
        }
    }
    
    func aplicarFiltros() {
        var resultado = productos
        
        // Filtrar por estado
        switch filtroActual {
        case .todos:
            break
        case .activos:
            resultado = resultado.filter { $0.estado }
        case .inactivos:
            resultado = resultado.filter { !$0.estado }
        }
        
        // Filtrar por búsqueda
        if !busqueda.isEmpty {
            let query = busqueda.lowercased()
            resultado = resultado.filter {
                $0.codigo.lowercased().contains(query) ||
                $0.descripcion.lowercased().contains(query)
            }
        }
        
        productosFiltrados = resultado
        onProductosUpdated?()
    }
    
    func setFiltro(_ filtro: FiltroProducto) {
        filtroActual = filtro
        aplicarFiltros()
    }
    
    func setBusqueda(_ texto: String) {
        busqueda = texto
        aplicarFiltros()
    }
    
    // MARK: - CRUD
    
    func addProducto(
        codigo: String,
        descripcion: String,
        categoria: Categoria?,
        marca: Marca?,
        unidad: Unidad?,
        imagen: Data?
    ) {
        let trimmedCodigo = codigo.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescripcion = descripcion.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedDescripcion.isEmpty else {
            onError?("La descripción no puede estar vacía")
            return
        }
        
        // Generar código si está vacío
        let codigoFinal: String
        if trimmedCodigo.isEmpty {
            codigoFinal = generarCodigoAutomatico()
        } else {
            // Verificar código único
            if productos.contains(where: { $0.codigo.lowercased() == trimmedCodigo.lowercased() }) {
                onError?("Ya existe un producto con ese código")
                return
            }
            codigoFinal = trimmedCodigo
        }
        
        let producto = Producto(
            codigo: codigoFinal,
            descripcion: trimmedDescripcion,
            categoria: categoria,
            marca: marca,
            unidad: unidad
        )
        producto.imagen = imagen
        
        context.insert(producto)
        
        do {
            try context.save()
            onSuccess?("Producto creado exitosamente")
            fetchProductos()
        } catch {
            onError?("Error al guardar: \(error.localizedDescription)")
        }
    }
    
    func updateProducto(
        _ producto: Producto,
        codigo: String,
        descripcion: String,
        categoria: Categoria?,
        marca: Marca?,
        unidad: Unidad?,
        imagen: Data?
    ) {
        let trimmedCodigo = codigo.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescripcion = descripcion.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedDescripcion.isEmpty else {
            onError?("La descripción no puede estar vacía")
            return
        }
        
        guard !trimmedCodigo.isEmpty else {
            onError?("El código no puede estar vacío")
            return
        }
        
        // Verificar código único (excluyendo el actual)
        if productos.contains(where: { $0.id != producto.id && $0.codigo.lowercased() == trimmedCodigo.lowercased() }) {
            onError?("Ya existe un producto con ese código")
            return
        }
        
        producto.codigo = trimmedCodigo
        producto.descripcion = trimmedDescripcion
        producto.categoria = categoria
        producto.marca = marca
        producto.unidad = unidad
        producto.imagen = imagen
        
        do {
            try context.save()
            onSuccess?("Producto actualizado")
            fetchProductos()
        } catch {
            onError?("Error al actualizar: \(error.localizedDescription)")
        }
    }
    
    func toggleEstado(_ producto: Producto) {
        producto.estado.toggle()
        
        do {
            try context.save()
            let estado = producto.estado ? "activado" : "desactivado"
            onSuccess?("Producto \(estado)")
            fetchProductos()
        } catch {
            onError?("Error al cambiar estado: \(error.localizedDescription)")
        }
    }
    
    func deleteProducto(_ producto: Producto) -> Bool {
        context.delete(producto)
        
        do {
            try context.save()
            onSuccess?("Producto eliminado")
            fetchProductos()
            return true
        } catch {
            onError?("Error al eliminar: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Helpers
    
    private func generarCodigoAutomatico() -> String {
        let existentes = productos.compactMap { producto -> Int? in
            let codigo = producto.codigo
            guard codigo.hasPrefix("PROD-") else { return nil }
            let numeroStr = codigo.replacingOccurrences(of: "PROD-", with: "")
            return Int(numeroStr)
        }
        
        let siguiente = (existentes.max() ?? 0) + 1
        return Producto.generarCodigo(secuencia: siguiente)
    }
    
    // MARK: - Fetch Auxiliares
    
    func fetchCategorias() -> [Categoria] {
        let descriptor = FetchDescriptor<Categoria>(
            predicate: #Predicate { $0.estado == true },
            sortBy: [SortDescriptor(\.nombre)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func fetchMarcas() -> [Marca] {
        let descriptor = FetchDescriptor<Marca>(
            predicate: #Predicate { $0.estado == true },
            sortBy: [SortDescriptor(\.nombre)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func fetchUnidades() -> [Unidad] {
        let descriptor = FetchDescriptor<Unidad>(
            predicate: #Predicate { $0.estado == true },
            sortBy: [SortDescriptor(\.nombre)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
}
