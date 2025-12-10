//
//  VentaViewModel.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import Foundation
import SwiftData

// Item del carrito (en memoria, no persistido hasta confirmar)
struct CarritoItem: Identifiable {
    let id = UUID()
    let producto: Producto
    let precio: Precio
    var cantidad: Int
    
    var subtotal: Double {
        Double(cantidad) * precio.precioUnitario
    }
    
    var subtotalFormateado: String {
        String(format: "S/ %.2f", subtotal)
    }
    
    var costo: Double {
        precio.costoNeto
    }
}

@MainActor
final class VentaViewModel {
    
    // MARK: - Callbacks
    var onProductosUpdated: (() -> Void)?
    var onCarritoUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: ((String) -> Void)?
    var onVentaCompletada: ((Pedido) -> Void)?
    
    // MARK: - Properties
    private(set) var productosDisponibles: [Producto] = []
    private(set) var productosFiltrados: [Producto] = []
    private(set) var carrito: [CarritoItem] = []
    private let context: ModelContext
    
    var busqueda: String = ""
    var clienteSeleccionado: Cliente?
    var tipoComprobante: TipoComprobante = .boleta
    
    // MARK: - Totales
    var subtotalCarrito: Double {
        carrito.reduce(0) { $0 + $1.subtotal }
    }
    
    var igvCarrito: Double {
        subtotalCarrito - (subtotalCarrito / 1.18)
    }
    
    var subtotalSinIGV: Double {
        subtotalCarrito / 1.18
    }
    
    var totalCarrito: Double {
        subtotalCarrito
    }
    
    var cantidadItems: Int {
        carrito.reduce(0) { $0 + $1.cantidad }
    }
    
    var carritoVacio: Bool {
        carrito.isEmpty
    }
    
    // Formateados
    var subtotalFormateado: String { String(format: "S/ %.2f", subtotalSinIGV) }
    var igvFormateado: String { String(format: "S/ %.2f", igvCarrito) }
    var totalFormateado: String { String(format: "S/ %.2f", totalCarrito) }
    
    init() {
        self.context = AppDelegate.sharedModelContainer.mainContext
    }
    
    // MARK: - Fetch Productos
    
    func fetchProductos() {
        let descriptor = FetchDescriptor<Producto>(
            predicate: #Predicate { $0.estado == true },
            sortBy: [SortDescriptor(\.descripcion, order: .forward)]
        )
        
        do {
            productosDisponibles = try context.fetch(descriptor)
            aplicarFiltros()
        } catch {
            onError?("Error al cargar productos: \(error.localizedDescription)")
        }
    }
    
    func aplicarFiltros() {
        var resultado = productosDisponibles.filter { $0.precioActivo != nil }
        
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
    
    func setBusqueda(_ texto: String) {
        busqueda = texto
        aplicarFiltros()
    }
    
    // MARK: - Carrito Operations
    
    func agregarAlCarrito(_ producto: Producto, cantidad: Int = 1) {
        guard let precio = producto.precioActivo else {
            onError?("El producto no tiene precio activo")
            return
        }
        
        // Verificar stock
        if producto.stockActual < cantidad {
            if producto.stockActual == 0 {
                onError?("Sin stock disponible")
            } else {
                onError?("Stock insuficiente. Disponible: \(producto.stockActual)")
            }
            return
        }
        
        // Verificar si ya está en el carrito
        if let index = carrito.firstIndex(where: { $0.producto.id == producto.id }) {
            let nuevaCantidad = carrito[index].cantidad + cantidad
            if nuevaCantidad > producto.stockActual {
                onError?("No hay suficiente stock. Disponible: \(producto.stockActual)")
                return
            }
            carrito[index].cantidad = nuevaCantidad
        } else {
            let item = CarritoItem(producto: producto, precio: precio, cantidad: cantidad)
            carrito.append(item)
        }
        
        onCarritoUpdated?()
    }
    
    func actualizarCantidad(itemId: UUID, cantidad: Int) {
        guard let index = carrito.firstIndex(where: { $0.id == itemId }) else { return }
        
        if cantidad <= 0 {
            carrito.remove(at: index)
        } else {
            let producto = carrito[index].producto
            if cantidad > producto.stockActual {
                onError?("Stock máximo disponible: \(producto.stockActual)")
                return
            }
            carrito[index].cantidad = cantidad
        }
        
        onCarritoUpdated?()
    }
    
    func incrementarCantidad(itemId: UUID) {
        guard let index = carrito.firstIndex(where: { $0.id == itemId }) else { return }
        actualizarCantidad(itemId: itemId, cantidad: carrito[index].cantidad + 1)
    }
    
    func decrementarCantidad(itemId: UUID) {
        guard let index = carrito.firstIndex(where: { $0.id == itemId }) else { return }
        actualizarCantidad(itemId: itemId, cantidad: carrito[index].cantidad - 1)
    }
    
    func eliminarDelCarrito(itemId: UUID) {
        carrito.removeAll { $0.id == itemId }
        onCarritoUpdated?()
    }
    
    func limpiarCarrito() {
        carrito.removeAll()
        clienteSeleccionado = nil
        onCarritoUpdated?()
    }
    
    // MARK: - Procesar Venta
    
    func procesarVenta(pagos: [(TipoPago, Double, String?)]) -> Bool {
        guard !carrito.isEmpty else {
            onError?("El carrito está vacío")
            return false
        }
        
        let totalPagado = pagos.reduce(0) { $0 + $1.1 }
        guard totalPagado >= totalCarrito else {
            onError?("El monto pagado es insuficiente")
            return false
        }
        
        // Obtener usuarios
        let currentUser = getCurrentUser()
        
        // Generar número de pedido
        let numeroPedido = generarNumeroPedido()
        
        // Crear pedido
        let pedido = Pedido(numeroPedido: numeroPedido, tipoComprobante: tipoComprobante)
        pedido.vendedor = currentUser
        pedido.cajero = currentUser
        pedido.cliente = clienteSeleccionado
        pedido.nombreCliente = clienteSeleccionado?.nombreCompleto
        
        context.insert(pedido)
        
        // Crear detalles y descontar stock
        for item in carrito {
            // Detalle pedido
            let detalle = DetallePedido(
                cantidad: item.cantidad,
                precioUnitario: item.precio.precioUnitario,
                costo: item.costo
            )
            detalle.pedido = pedido
            detalle.producto = item.producto
            detalle.precio = item.precio
            pedido.detalles.append(detalle)
            context.insert(detalle)
            
            // Descontar stock
            if let stock = item.producto.stock {
                let movimiento = MovimientoStock(
                    tipo: .venta,
                    cantidad: item.cantidad,
                    cantidadAnterior: stock.cantidad,
                    motivo: "Venta \(numeroPedido)"
                )
                movimiento.usuario = currentUser
                movimiento.stock = stock
                movimiento.pedido = pedido
                
                stock.cantidad = max(0, stock.cantidad - item.cantidad)
                stock.ultimaActualizacion = Date()
                stock.movimientos.append(movimiento)
                pedido.movimientosStock.append(movimiento)
                context.insert(movimiento)
            }
        }
        
        // Crear pagos
        for (tipoPago, monto, referencia) in pagos {
            let pago = PagoPedido(tipoPago: tipoPago, monto: monto, referencia: referencia)
            pago.pedido = pedido
            pedido.pagos.append(pago)
            context.insert(pago)
        }
        
        // Calcular totales
        pedido.recalcularTotales()
        pedido.estado = .completado
        
        do {
            try context.save()
            onSuccess?("Venta completada: \(numeroPedido)")
            onVentaCompletada?(pedido)
            limpiarCarrito()
            return true
        } catch {
            onError?("Error al procesar venta: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Helpers
    
    private func getCurrentUser() -> User? {
        guard let userIdString = UserDefaults.standard.string(forKey: "currentUserId"),
              let userId = UUID(uuidString: userIdString) else {
            return nil
        }
        
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.id == userId }
        )
        
        return try? context.fetch(descriptor).first
    }
    
    private func generarNumeroPedido() -> String {
        let descriptor = FetchDescriptor<Pedido>(
            predicate: #Predicate { pedido in
                pedido.tipoComprobante == tipoComprobante
            },
            sortBy: [SortDescriptor(\.fecha, order: .reverse)]
        )
        
        let pedidos = (try? context.fetch(descriptor)) ?? []
        let ultimoNumero = pedidos.first?.numeroPedido
        
        var secuencia = 1
        if let ultimo = ultimoNumero {
            let partes = ultimo.split(separator: "-")
            if partes.count == 2, let num = Int(partes[1]) {
                secuencia = num + 1
            }
        }
        
        return Pedido.generarNumero(tipo: tipoComprobante, secuencia: secuencia)
    }
    
    // MARK: - Clientes
    
    func fetchClientes() -> [Cliente] {
        let descriptor = FetchDescriptor<Cliente>(
            predicate: #Predicate { $0.estado == true },
            sortBy: [SortDescriptor(\.nombres)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
}
