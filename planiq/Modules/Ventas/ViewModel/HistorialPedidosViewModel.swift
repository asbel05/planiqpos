//
//  HistorialPedidosViewModel.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import Foundation
import SwiftData

enum FiltroPeriodo: Int, CaseIterable {
    case todos = 0
    case hoy = 1
    case semana = 2
    case mes = 3
    
    var titulo: String {
        switch self {
        case .todos: return "Todos"
        case .hoy: return "Hoy"
        case .semana: return "Semana"
        case .mes: return "Mes"
        }
    }
}

@MainActor
final class HistorialPedidosViewModel {
    
    // MARK: - Callbacks
    var onPedidosUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: ((String) -> Void)?
    
    // MARK: - Properties
    private(set) var pedidos: [Pedido] = []
    private(set) var pedidosFiltrados: [Pedido] = []
    private let context: ModelContext
    
    var filtroActual: FiltroPeriodo = .todos
    var busqueda: String = ""
    
    // Stats
    var totalVentas: Double {
        pedidosFiltrados.filter { $0.estado == .completado }.reduce(0) { $0 + $1.total }
    }
    
    var totalVentasFormateado: String {
        String(format: "S/ %.2f", totalVentas)
    }
    
    var cantidadPedidos: Int {
        pedidosFiltrados.count
    }
    
    init() {
        self.context = AppDelegate.sharedModelContainer.mainContext
    }
    
    // MARK: - Fetch
    
    func fetchPedidos() {
        let descriptor = FetchDescriptor<Pedido>(
            sortBy: [SortDescriptor(\.fecha, order: .reverse)]
        )
        
        do {
            pedidos = try context.fetch(descriptor)
            aplicarFiltros()
        } catch {
            onError?("Error al cargar pedidos: \(error.localizedDescription)")
        }
    }
    
    func aplicarFiltros() {
        var resultado = pedidos
        
        // Filtrar por periodo
        let calendar = Calendar.current
        let ahora = Date()
        
        switch filtroActual {
        case .todos:
            break
        case .hoy:
            resultado = resultado.filter { calendar.isDateInToday($0.fecha) }
        case .semana:
            let inicioSemana = calendar.date(byAdding: .day, value: -7, to: ahora)!
            resultado = resultado.filter { $0.fecha >= inicioSemana }
        case .mes:
            let inicioMes = calendar.date(byAdding: .month, value: -1, to: ahora)!
            resultado = resultado.filter { $0.fecha >= inicioMes }
        }
        
        // Filtrar por búsqueda
        if !busqueda.isEmpty {
            let query = busqueda.lowercased()
            resultado = resultado.filter {
                $0.numeroPedido.lowercased().contains(query) ||
                $0.clienteNombre.lowercased().contains(query)
            }
        }
        
        pedidosFiltrados = resultado
        onPedidosUpdated?()
    }
    
    func setFiltro(_ filtro: FiltroPeriodo) {
        filtroActual = filtro
        aplicarFiltros()
    }
    
    func setBusqueda(_ texto: String) {
        busqueda = texto
        aplicarFiltros()
    }
    
    // MARK: - Acciones
    
    func cancelarPedido(_ pedido: Pedido) {
        guard pedido.estado == .pendiente else {
            onError?("Solo se pueden cancelar pedidos pendientes")
            return
        }
        
        pedido.estado = .cancelado
        
        // Devolver stock
        for movimiento in pedido.movimientosStock where movimiento.tipo == .venta {
            if let stock = movimiento.stock {
                let devolucion = MovimientoStock(
                    tipo: .devolucion,
                    cantidad: movimiento.cantidad,
                    cantidadAnterior: stock.cantidad,
                    motivo: "Cancelación de \(pedido.numeroPedido)"
                )
                devolucion.stock = stock
                devolucion.pedido = pedido
                
                stock.cantidad += movimiento.cantidad
                stock.ultimaActualizacion = Date()
                stock.movimientos.append(devolucion)
                context.insert(devolucion)
            }
        }
        
        do {
            try context.save()
            onSuccess?("Pedido cancelado")
            fetchPedidos()
        } catch {
            onError?("Error al cancelar: \(error.localizedDescription)")
        }
    }
}
