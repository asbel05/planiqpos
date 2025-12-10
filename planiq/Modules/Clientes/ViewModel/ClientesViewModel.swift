//
//  ClientesViewModel.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import Foundation
import SwiftData

@MainActor
final class ClientesViewModel {
    
    // MARK: - Callbacks
    var onClientesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: ((String) -> Void)?
    
    // MARK: - Properties
    private(set) var clientes: [Cliente] = []
    private(set) var clientesFiltrados: [Cliente] = []
    private let context: ModelContext
    
    var busqueda: String = ""
    
    init() {
        self.context = AppDelegate.sharedModelContainer.mainContext
    }
    
    // MARK: - Fetch
    
    func fetchClientes() {
        let descriptor = FetchDescriptor<Cliente>(
            sortBy: [SortDescriptor(\.nombres, order: .forward)]
        )
        
        do {
            clientes = try context.fetch(descriptor)
            aplicarFiltros()
        } catch {
            onError?("Error al cargar clientes: \(error.localizedDescription)")
        }
    }
    
    func aplicarFiltros() {
        var resultado = clientes.filter { $0.estado }
        
        if !busqueda.isEmpty {
            let query = busqueda.lowercased()
            resultado = resultado.filter {
                $0.nombreCompleto.lowercased().contains(query) ||
                $0.numeroDocumento.contains(query)
            }
        }
        
        clientesFiltrados = resultado
        onClientesUpdated?()
    }
    
    func setBusqueda(_ texto: String) {
        busqueda = texto
        aplicarFiltros()
    }
    
    // MARK: - CRUD
    
    func addCliente(nombres: String, apellidos: String?, tipoDocumento: TipoDocumento, numeroDocumento: String, telefono: String?, email: String?, direccion: String?) {
        let trimmedNombres = nombres.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDocumento = numeroDocumento.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedNombres.isEmpty else {
            onError?("El nombre es obligatorio")
            return
        }
        
        guard !trimmedDocumento.isEmpty else {
            onError?("El número de documento es obligatorio")
            return
        }
        
        // Verificar documento único
        if clientes.contains(where: { $0.numeroDocumento == trimmedDocumento }) {
            onError?("Ya existe un cliente con ese documento")
            return
        }
        
        let cliente = Cliente(
            nombres: trimmedNombres,
            apellidos: apellidos?.trimmingCharacters(in: .whitespacesAndNewlines),
            tipoDocumento: tipoDocumento,
            numeroDocumento: trimmedDocumento
        )
        cliente.telefono = telefono?.trimmingCharacters(in: .whitespacesAndNewlines)
        cliente.email = email?.trimmingCharacters(in: .whitespacesAndNewlines)
        cliente.direccion = direccion?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        context.insert(cliente)
        
        do {
            try context.save()
            onSuccess?("Cliente creado exitosamente")
            fetchClientes()
        } catch {
            onError?("Error al guardar: \(error.localizedDescription)")
        }
    }
    
    func updateCliente(_ cliente: Cliente, nombres: String, apellidos: String?, tipoDocumento: TipoDocumento, numeroDocumento: String, telefono: String?, email: String?, direccion: String?) {
        let trimmedNombres = nombres.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDocumento = numeroDocumento.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedNombres.isEmpty else {
            onError?("El nombre es obligatorio")
            return
        }
        
        guard !trimmedDocumento.isEmpty else {
            onError?("El número de documento es obligatorio")
            return
        }
        
        // Verificar documento único (excluyendo el actual)
        if clientes.contains(where: { $0.id != cliente.id && $0.numeroDocumento == trimmedDocumento }) {
            onError?("Ya existe un cliente con ese documento")
            return
        }
        
        cliente.nombres = trimmedNombres
        cliente.apellidos = apellidos?.trimmingCharacters(in: .whitespacesAndNewlines)
        cliente.tipoDocumento = tipoDocumento
        cliente.numeroDocumento = trimmedDocumento
        cliente.telefono = telefono?.trimmingCharacters(in: .whitespacesAndNewlines)
        cliente.email = email?.trimmingCharacters(in: .whitespacesAndNewlines)
        cliente.direccion = direccion?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try context.save()
            onSuccess?("Cliente actualizado")
            fetchClientes()
        } catch {
            onError?("Error al actualizar: \(error.localizedDescription)")
        }
    }
    
    func toggleEstado(_ cliente: Cliente) {
        cliente.estado.toggle()
        
        do {
            try context.save()
            let estado = cliente.estado ? "activado" : "desactivado"
            onSuccess?("Cliente \(estado)")
            fetchClientes()
        } catch {
            onError?("Error al cambiar estado: \(error.localizedDescription)")
        }
    }
    
    func deleteCliente(_ cliente: Cliente) -> Bool {
        if cliente.pedidosCount > 0 {
            onError?("No se puede eliminar: tiene \(cliente.pedidosCount) pedidos asociados")
            return false
        }
        
        context.delete(cliente)
        
        do {
            try context.save()
            onSuccess?("Cliente eliminado")
            fetchClientes()
            return true
        } catch {
            onError?("Error al eliminar: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Búsqueda por documento
    
    func buscarPorDocumento(_ documento: String) -> Cliente? {
        return clientes.first { $0.numeroDocumento == documento }
    }
}
