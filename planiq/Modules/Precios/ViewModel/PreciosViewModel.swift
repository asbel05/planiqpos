//
//  PreciosViewModel.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import Foundation
import SwiftData

@MainActor
final class PreciosViewModel {
    
    // MARK: - Callbacks
    var onPreciosUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: ((String) -> Void)?
    
    // MARK: - Properties
    private(set) var productos: [Producto] = []
    private(set) var productosFiltrados: [Producto] = []
    private let context: ModelContext
    
    var busqueda: String = ""
    
    init() {
        self.context = AppDelegate.sharedModelContainer.mainContext
    }
    
    // MARK: - Fetch
    
    func fetchProductosConPrecios() {
        let descriptor = FetchDescriptor<Producto>(
            predicate: #Predicate { $0.estado == true },
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
        
        if !busqueda.isEmpty {
            let query = busqueda.lowercased()
            resultado = resultado.filter {
                $0.codigo.lowercased().contains(query) ||
                $0.descripcion.lowercased().contains(query)
            }
        }
        
        productosFiltrados = resultado
        onPreciosUpdated?()
    }
    
    func setBusqueda(_ texto: String) {
        busqueda = texto
        aplicarFiltros()
    }
    
    // MARK: - CRUD Precios
    
    func addPrecio(
        producto: Producto,
        precioUnitario: Double,
        precioMayorista: Double,
        costoNeto: Double,
        costoBase: Double,
        unidadMinima: Int,
        unidadCompra: Int,
        unidadBonificacion: Int,
        descuento1: Double,
        descuento2: Double,
        descuento3: Double,
        esActivo: Bool
    ) {
        guard precioUnitario > 0 else {
            onError?("El precio unitario debe ser mayor a 0")
            return
        }
        
        // Si el nuevo precio es activo, desactivar los demás
        if esActivo {
            desactivarPreciosDeProducto(producto)
        }
        
        let precio = Precio(
            precioUnitario: precioUnitario,
            precioMayorista: precioMayorista,
            costoNeto: costoNeto,
            costoBase: costoBase,
            unidadMinima: unidadMinima,
            unidadCompra: unidadCompra,
            unidadBonificacion: unidadBonificacion,
            descuento1: descuento1,
            descuento2: descuento2,
            descuento3: descuento3,
            esActivo: esActivo
        )
        
        precio.producto = producto
        producto.precios.append(precio)
        context.insert(precio)
        
        do {
            try context.save()
            onSuccess?("Precio agregado exitosamente")
            fetchProductosConPrecios()
        } catch {
            onError?("Error al guardar: \(error.localizedDescription)")
        }
    }
    
    func updatePrecio(
        _ precio: Precio,
        precioUnitario: Double,
        precioMayorista: Double,
        costoNeto: Double,
        costoBase: Double,
        unidadMinima: Int,
        unidadCompra: Int,
        unidadBonificacion: Int,
        descuento1: Double,
        descuento2: Double,
        descuento3: Double,
        esActivo: Bool
    ) {
        guard precioUnitario > 0 else {
            onError?("El precio unitario debe ser mayor a 0")
            return
        }
        
        // Si se activa este precio, desactivar los demás del mismo producto
        if esActivo, let producto = precio.producto {
            desactivarPreciosDeProducto(producto, excepto: precio)
        }
        
        precio.precioUnitario = precioUnitario
        precio.precioMayorista = precioMayorista
        precio.costoNeto = costoNeto
        precio.costoBase = costoBase
        precio.unidadMinima = unidadMinima
        precio.unidadCompra = unidadCompra
        precio.unidadBonificacion = unidadBonificacion
        precio.descuento1 = descuento1
        precio.descuento2 = descuento2
        precio.descuento3 = descuento3
        precio.esActivo = esActivo
        
        do {
            try context.save()
            onSuccess?("Precio actualizado")
            fetchProductosConPrecios()
        } catch {
            onError?("Error al actualizar: \(error.localizedDescription)")
        }
    }
    
    func activarPrecio(_ precio: Precio) {
        guard let producto = precio.producto else { return }
        
        // Desactivar todos los demás precios del producto
        desactivarPreciosDeProducto(producto)
        
        // Activar este precio
        precio.esActivo = true
        
        do {
            try context.save()
            onSuccess?("Precio activado")
            fetchProductosConPrecios()
        } catch {
            onError?("Error al activar precio: \(error.localizedDescription)")
        }
    }
    
    func deletePrecio(_ precio: Precio) -> Bool {
        context.delete(precio)
        
        do {
            try context.save()
            onSuccess?("Precio eliminado")
            fetchProductosConPrecios()
            return true
        } catch {
            onError?("Error al eliminar: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Helpers
    
    private func desactivarPreciosDeProducto(_ producto: Producto, excepto: Precio? = nil) {
        for precio in producto.precios {
            if excepto == nil || precio.id != excepto?.id {
                precio.esActivo = false
            }
        }
    }
    
    func fetchProductos() -> [Producto] {
        let descriptor = FetchDescriptor<Producto>(
            predicate: #Predicate { $0.estado == true },
            sortBy: [SortDescriptor(\.descripcion)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
}
