//
//  ArtiSanApp.swift
//  ArtiSan
//
//  Created by Michael Steeber on 9/2/24.
//

import SwiftUI

@main
struct ArtiSanApp: App {
    var body: some Scene {
        WindowGroup {
            SearchView()
                .frame(minWidth: 400, maxWidth: 400, minHeight: 400, maxHeight: 1200)
                .onAppear {
                    /// Disables opening a new tab
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 400, height: 600)
        .commands {
            /// Removed unused menus
            CommandGroup(replacing: .newItem) { EmptyView() }
            CommandGroup(replacing: .appSettings) { EmptyView() }
            CommandGroup(replacing: .appVisibility) { EmptyView() }
            CommandGroup(replacing: .systemServices) { EmptyView() }
        }
        
        WindowGroup("Image", for: Album.self) { $album in
            ImageView(album: album ?? Album.fallback)
                .frame(width: 600, height: 600)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}
