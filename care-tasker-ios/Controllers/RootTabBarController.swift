//
//  RootTabBarController.swift
//  care-taskerApp
//
//  Created by Michael Forbes on 19/9/2026.
//
import UIKit
import HotwireNative

class RootTabBarController: UITabBarController {

    private var navigators: [Navigator] = []

    func configure(with tabs: [TabConfiguration]) {

        let controllers = tabs.map { tab -> UIViewController in

            let navigator = Navigator(
                configuration: .init(
                    name: tab.mobile_title,
                    startLocation: URL(string: tab.ios_url)!
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
}
