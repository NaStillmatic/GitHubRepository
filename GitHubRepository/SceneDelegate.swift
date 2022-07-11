//
//  SceneDelegate.swift
//  GitHubRepository
//
//  Created by HwangByungJo  on 2022/07/08.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?


  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    window = UIWindow(windowScene: windowScene)
    
    let rootViewController = RepositoryListViewController()
    let rootNaviationConroller = UINavigationController(rootViewController: rootViewController)
    window?.rootViewController = rootNaviationConroller
    window?.makeKeyAndVisible()
  }

}

