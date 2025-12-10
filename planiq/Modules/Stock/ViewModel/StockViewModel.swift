//
//  StockViewModel.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import Foundation
import SwiftData

enum FiltroStock: Int, CaseIterable {
    case todos = 0
    case stockBajo = 1
    case sinStock = 2
    
    var titulo: String {
        switch self {
        case .todos: return "Todos"
        case .stockBajo: return "Stock Bajo"
        case .sinStock: return "Sin Stock"
        }
    }
}

@MainActor
final class StockViewModel {
    
    // MARK: - Callbacks
    var onStockUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: ((String) -> Void)?
    
    // MARK: - Properties
    private(set) var productos: [Producto] = []
    private(set) var productosFiltrados: [Producto] = []
    private let context: ModelContext
    
    var filtroActual: FiltroStock = .todos
    var busqueda: String = ""
    
    // Stats
    var totalProductos: Int { productos.count }
    var totalStockBajo: Int { productos.filter { $0.tieneStockBajo }.count }
    var totalSinStock: Int { productos.filter { $0.estadoStock == .sinStock }.count }
    
    init() {
        self.context = AppDelegate.sharedModelContainer.mainContext
    }
    
    // MARK: - Fetch
    
    func fetchProductosConStock() {
        let descriptor = FetchDescriptor<Producto>(
            predicate: #Predicate { $0.estado == true },
            sortBy: [SortDescriptor(\.descripcion, order: .forward)]
        )
        
        do {
            productos = try context.fetch(descriptor)
            // Asegurar que cada producto tenga stock
            for producto in productos {
                if producto.stock == nil {
                    crearStockParaProducto(producto)
                }
            }
            aplicarFiltros()
        } catch {
            onError?("Error al cargar productos: \(error.localizedDescription)")
        }
    }
    
    func aplicarFiltros() {
        var resultado = productos
        
        // Filtrar por estado de stock
        switch filtroActual {
        case .todos:
            break
        case .stockBajo:
            resultado = resultado.filter { $0.tieneStockBajo }
        case .sinStock:
            resultado = resultado.filter { $0.estadoStock == .sinStock }
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
        onStockUpdated?()
    }
    
    func setFiltro(_ filtro: FiltroStock) {
        filtroActual = filtro
        aplicarFiltros()
    }
    
    func setBusqueda(_ texto: String) {
        busqueda = texto
        aplicarFiltros()
    }
    
    // MARK: - Stock Operations
    
    private func crearStockParaProducto(_ producto: Producto) {
        let stock = Stock(cantidad: 0, stockMinimo: 5)
        stock.producto = producto
        producto.stock = stock
        context.insert(stock)
        
        do {
            try context.save()
        } catch {
            print("Error creando stock: \(error)")
        }
    }
    
    func ajustarStock(producto: Producto, tipo: TipoMovimiento, cantidad: Int, motivo: String, usuario: User?) {
        guard let stock = producto.stock else {
            onError?("El producto no tiene stock asociado")
            return
        }
        
        let cantidadAnterior = stock.cantidad
        
        // Validar salida
        if tipo == .salida && cantidad > cantidadAnterior {
            onError?("No hay suficiente stock. Stock actual: \(cantidadAnterior)")
            return
        }
        
        // Crear movimiento
        let movimiento = MovimientoStock(
            tipo: tipo,
            cantidad: cantidad,
            cantidadAnterior: cantidadAnterior,
            motivo: motivo.isEmpty ? nil : motivo
        )
        movimiento.usuario = usuario
        movimiento.stock = stock
        
        // Actualizar stock
        switch tipo {
        case .entrada, .devolucion:
            stock.cantidad += cantidad
        case .salida, .venta:
            stock.cantidad = max(0, stock.cantidad - cantidad)
        case .ajuste:
            stock.cantidad = cantidad
        }
        
        stock.ultimaActualizacion = Date()
        stock.movimientos.append(movimiento)
        context.insert(movimiento)
        
        do {
            try context.save()
            let mensaje = switch tipo {
            case .entrada: "Entrada de \(cantidad) unidades registrada"
            case .salida: "Salida de \(cantidad) unidades registrada"
            case .ajuste: "Stock ajustado a \(cantidad) unidades"
            case .devolucion: "Devolución de \(cantidad) unidades registrada"
            case .venta: "Venta de \(cantidad) unidades registrada"
            }
            onSuccess?(mensaje)
            fetchProductosConStock()
        } catch {
            onError?("Error al ajustar stock: \(error.localizedDescription)")
        }
    }
    
    func actualizarStockMinimo(producto: Producto, nuevoMinimo: Int) {
        guard let stock = producto.stock else { return }
        
        stock.stockMinimo = nuevoMinimo
        stock.ultimaActualizacion = Date()
        
        do {
            try context.save()
            onSuccess?("Stock mínimo actualizado")
            fetchProductosConStock()
        } catch {
            onError?("Error al actualizar: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Historial
    
    func getMovimientos(para producto: Producto) -> [MovimientoStock] {
        return producto.stock?.movimientos.sorted { $0.fecha > $1.fecha } ?? []
    }
    
    // MARK: - Usuario Actual
    
    func getCurrentUser() -> User? {
        guard let userIdString = UserDefaults.standard.string(forKey: "currentUserId"),
              let userId = UUID(uuidString: userIdString) else {
            return nil
        }
        
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.id == userId }
        )
        
        return try? context.fetch(descriptor).first
    }
}
