//
//  ConfigurationService.swift
//  care-taskerApp
//
//  Created by Michael Forbes on 19/9/2026.
//


import Foundation

class ConfigurationService {

    func loadTabs() async throws -> [TabConfiguration] {

        let url = URL(
            string: "http://127.0.0.1:3000/configurations/current_user_tabs"
        )!

        let (data, _) = try await URLSession.shared.data(
            from: url
        )

        return try JSONDecoder().decode(
            [TabConfiguration].self,
            from: data
        )
    }
}