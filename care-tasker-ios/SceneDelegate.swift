//
//  SceneDelegate.swift
//  care-tasker-ios
//
//  Created by Michael Forbes on 19/9/2026.
//
import UIKit
import HotwireNative

let baseURL = URL(string: "http://127.0.0.1:3000")!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var tabsLoaded = false

    private lazy var navigator = Navigator(
        configuration: .init(
            name: "main",
            startLocation: baseURL
        )
    )

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        window.rootViewController = navigator.rootViewController

        window.makeKeyAndVisible()

        navigator.start()

        //
        // Temporary bootstrap.
        //
        Task {
            await waitForAuthenticatedSession()
        }
    }

    private func waitForAuthenticatedSession() async {

        while !tabsLoaded {

            do {

                let tabs = try await ConfigurationService()
                    .loadTabs()

                tabsLoaded = true

                await MainActor.run {

                    let tabBarController =
                        RootTabBarController()

                    tabBarController.configure(
                        with: tabs
                    )

                    self.window?.rootViewController =
                        tabBarController
                }

            } catch {

                //
                // User not authenticated yet.
                //
            }

            try? await Task.sleep(
                for: .seconds(2)
            )
        }
    }
}
