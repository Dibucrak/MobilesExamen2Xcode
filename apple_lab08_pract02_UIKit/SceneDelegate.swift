import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // 1. Capturamos la escena
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 2. Creamos la ventana principal programáticamente
        let window = UIWindow(windowScene: windowScene)
        
        // 3. Ubicamos tu archivo Main.storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // 4. Forzamos a que la pantalla inicial (tu Tab Bar) sea la raíz
        window.rootViewController = storyboard.instantiateInitialViewController()
        
        // 5. Retenemos la ventana y la hacemos visible
        self.window = window
        window.makeKeyAndVisible()
    }
}
