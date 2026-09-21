//
//  RootTabBarController.swift
//  care-tasker-ios
//

import UIKit
import HotwireNative

class RootTabBarController: UITabBarController {

    var navigators: [Navigator] = []

    func configure(with tabs: [TabConfiguration]) {

        navigators.removeAll()

        let controllers = tabs.map { tab -> UIViewController in

            let navigator = Navigator(
                configuration: .init(
                    name: tab.mobile_title,
                    startLocation: URL(string: tab.mobile_url)!
                )
            )

            navigators.append(navigator)

            let controller = navigator.rootViewController

            controller.tabBarItem = UITabBarItem(
                title: tab.mobile_title,
                image: UIImage(systemName: tab.ios_icon),
                selectedImage: nil
            )

            navigator.start()

            return controller
        }

        viewControllers = controllers
    }

    func rebuildTabs(with tabs: [TabConfiguration]) {

        let currentIndex = selectedIndex

        let controllers = tabs.map { tab -> UIViewController in

            let navigator = Navigator(
                configuration: .init(
                    name: tab.mobile_title,
                    startLocation: URL(string: tab.mobile_url)!
                )
            )
            let controller = navigator.rootViewController

            controller.tabBarItem = UITabBarItem(
                title: tab.mobile_title,
                image: UIImage(systemName: tab.ios_icon),
                selectedImage: nil
            )
            navigator.start()

            return controller
        }
        viewControllers = controllers

        if currentIndex < controllers.count {
            selectedIndex = currentIndex
        }
    }
}
