//
//  SearchView.swift
//  ArtiSan
//
//  Created by Michael Steeber on 9/2/24.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.openWindow) var openWindow
    @State private var searchText = ""
    @State private var searchResults: [Album]?
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(searchText: $searchText, searchResults: $searchResults)
            Divider()
            SearchResultsView(searchResults: $searchResults)
        }
    }
}

#Preview {
    SearchView()
}
