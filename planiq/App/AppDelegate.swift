//
//  AppDelegate.swift
//  planiq
//
//  Created by Asbel on 8/12/25.
//

import UIKit
import SwiftData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Categoria.self,
            Marca.self,
            Unidad.self,
            Producto.self,
            Precio.self,
            Stock.self,
            MovimientoStock.self,
            Cliente.self,
            Pedido.self,
            DetallePedido.self,
            PagoPedido.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
