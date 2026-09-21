//
//  SceneDelegate.swift
//  care-tasker-ios
//

import UIKit
import HotwireNative

let baseURL = URL(string: "http://127.0.0.1:3000")!

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var loginNavigator: Navigator!

    private var nativeTabsVisible = false

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

        showLoginScreen()

        window.makeKeyAndVisible()
    }

    // MARK: Login Screen

    @MainActor
    private func showLoginScreen() {

        loginNavigator = Navigator(
            configuration: .init(
                name: "main",
                startLocation: baseURL
            )
        )

        window?.rootViewController =
            loginNavigator.rootViewController

        loginNavigator.start()
    }

    // MARK: First Login

    @MainActor
    private func showTabBar(
        tabs: [TabConfiguration]
    ) {

        let controller =
            RootTabBarController()

        controller.configure(with: tabs)

        window?.rootViewController =
            controller
    }

    // MARK: Tab Refresh

    @MainActor
    private func refreshTabBar(
        tabs: [TabConfiguration]
    ) {

        guard let controller =
            window?.rootViewController
                as? RootTabBarController else {

            showTabBar(tabs: tabs)
            return
        }

        controller.rebuildTabs(with: tabs)
    }

    private func loadTabs() async {

        do {

            let tabs =
                try await ConfigurationService()
                    .loadTabs()

            await MainActor.run {

                let controller =
                    RootTabBarController()

                controller.configure(with: tabs)

                self.window?.rootViewController =
                    controller
            }

        } catch {

            print(error)
        }
    }

    private func refreshTabs(returnTo path: String?) async {
        do {
            let tabs =
            try await ConfigurationService()
                .loadTabs()
            
            await MainActor.run {
                
                let selectedIndex =
                (window?.rootViewController
                 as? UITabBarController)?
                    .selectedIndex ?? 0
                
                let controller =
                RootTabBarController()
                
                controller.configure(with: tabs)
                
                controller.selectedIndex =
                min(
                    selectedIndex,
                    tabs.count - 1
                )
                
                window?.rootViewController =
                controller
            }
            if let path {
                
                let url = baseURL.appending(path: path)
                
                if let tabController =
                    window?.rootViewController as? RootTabBarController {
                    
                    let currentIndex = tabController.selectedIndex
                    
                    if currentIndex < tabController.navigators.count {
                        
                        let navigator =
                        tabController.navigators[currentIndex]
                        
                        navigator.route(url)
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    // MARK: Custom URLs

    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {

        guard let url =
            URLContexts.first?.url else {
            return
        }

        guard url.scheme == "caretasker" else {
            return
        }

        switch url.host {

        case "login":

            Task {
                await loadTabs()
            }
            nativeTabsVisible = true

        case "refresh":
            let components = URLComponents(
                    url: url,
                    resolvingAgainstBaseURL: false
                )
            let currentURL =
                components?
                    .queryItems?
                    .first(where: { $0.name == "url" })?
                    .value
            Task {
                await refreshTabs(
                    returnTo: currentURL
                )
            }

        case "logout":
            guard nativeTabsVisible else {
                return
            }
            Task { @MainActor in
                showLoginScreen()
            }
            nativeTabsVisible = false

        default:
            break
        }
    }
}
