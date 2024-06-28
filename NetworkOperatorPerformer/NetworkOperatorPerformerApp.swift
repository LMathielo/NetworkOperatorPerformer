//
//  NetworkOperatorPerformerApp.swift
//  NetworkOperatorPerformer
//
//  Created by Lucas Mathielo on 26/06/24.
//

import SwiftUI
import ImageDownloader

@main
struct NetworkOperatorPerformerApp: App {
    var body: some Scene {
        WindowGroup {
            ImageDownloader.View()
        }
    }
}
