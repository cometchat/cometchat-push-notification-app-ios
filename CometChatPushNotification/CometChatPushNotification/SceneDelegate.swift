//
//  SceneDelegate.swift
//  CometChatPushNotification
//
//  Created by SuryanshBisen on 05/09/23.
//

import UIKit
import CometChatUIKitSwift
import CometChatSDK
import PushKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
  
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // MARK: - To set default theme, uncommented the commented line.
        CometChatTheme.defaultAppearance()
        let palette = Palette()
        palette.set(background: .purple)
        palette.set(accent: .cyan)
        palette.set(primary: .green)
        palette.set(error: .red)
        palette.set(success: .yellow)
        palette.set(secondary: .orange)
        
        let family = CometChatFontFamily(regular: "CourierNewPSMT", medium: "CourierNewPS-BoldMT", bold: "CourierNewPS-BoldMT")
        var typography = Typography()
        typography.overrideFont(family: family)
        
        if CometChat.getLoggedInUser() != nil {
            presentChatWindow()
        }
        
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func presentChatWindow() {
        let mainVC = CometChatConversationsWithMessages()
        let navigationController: UINavigationController = UINavigationController(rootViewController: mainVC)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.prefersLargeTitles = true
        
        var logoutImage = UIImage(systemName: "arrow.uturn.left")
        let messageButton = UIBarButtonItem(image: logoutImage, style: .plain, target: self, action: #selector(self.onLogoutButtonClicked))
        mainVC.navigationItem.leftBarButtonItem = messageButton
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [ .foregroundColor:  UIColor.label,.font: UIFont.boldSystemFont(ofSize: 20) as Any]
        navBarAppearance.shadowColor = .clear
        navBarAppearance.backgroundColor = .systemGray5
        navigationController.navigationBar.standardAppearance = navBarAppearance
        navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController.navigationBar.isTranslucent = true
        
        guard let window = self.window else {
                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
                return
        }
        
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
        
    }
    public func deRegisterPushNotificationExtention() {
        CometChatNotifications.unregisterPushToken { success in
            print("unregisterPushToken: \(success)")
        } onError: { error in
            print("unregisterPushToken: \(error.errorCode) \(error.errorDescription)")
        }
        
        
    }
    
    @objc func onLogoutButtonClicked() {
        DispatchQueue.main.async {
            CustomLoader.instance.showLoaderView()
        }
        
        self.deRegisterPushNotificationExtention()
        CometChatUIKit.logout(user: CometChat.getLoggedInUser()!) { status in
            
            DispatchQueue.main.async {
                CustomLoader.instance.hideLoaderView()
            }
            
            switch status {
            case .success(_):
                print("Logout Success")
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "Login")
                
                let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                
                guard let window = self.window else {
                    self.window?.rootViewController = vc
                    self.window?.makeKeyAndVisible()
                    return
                }
                
                
                window.rootViewController = navigationController
                window.makeKeyAndVisible()
                UIView.transition(with: window,
                                      duration: 0.3,
                                      options: .transitionCrossDissolve,
                                      animations: nil,
                                      completion: nil)

                
                
            case .onError(_):
                print("Logout failed")
            }
            
        }
    }


}

