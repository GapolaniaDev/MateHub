import SwiftUI

struct TabBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                setupTabBarAppearance()
            }
    }
    
    private func setupTabBarAppearance() {
        // Configurar apariencia del tab bar
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        
        // Fondo del tab bar
        tabBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        
        // Configurar items normales
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray2
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray2,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Configurar items seleccionados
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        
        // Agregar sombra sutil
        tabBarAppearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
        
        // Aplicar la apariencia
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Configurar tint color para elementos seleccionados
        UITabBar.appearance().tintColor = UIColor.systemBlue
        UITabBar.appearance().unselectedItemTintColor = UIColor.systemGray2
    }
}

extension View {
    func customTabBar() -> some View {
        self.modifier(TabBarModifier())
    }
}