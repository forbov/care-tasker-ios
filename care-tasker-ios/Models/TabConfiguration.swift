//
//  TabConfiguration.swift
//  care-taskerApp
//
//  Created by Michael Forbes on 19/9/2026.
//
import Foundation

struct TabConfiguration: Codable {
    let mobile_title: String
    let title: String
    let url: String
    let ios_url: String
    let fi_icon: String
    let ios_icon: String
    let android_icon: String
    let web_link: Bool
    let active: Bool
}
