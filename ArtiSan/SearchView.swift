//
//  SearchView.swift
//  ArtiSan
//
//  Created by Michael Steeber on 9/2/24.
//

import SwiftUI

/// The main app view.
struct SearchView: View {
    @State private var searchText = ""
    @State private var searchResults: [Album]?
    @State private var isSearching = false
    
    var body: some View {
        /// A zIndex must be set so that SearchResultsView  appears below SearchBar.
        VStack(spacing: 0) {
            SearchBar(searchText: $searchText, searchResults: $searchResults, isSearching: $isSearching)
                .zIndex(1)
            SearchResultsView(searchResults: $searchResults, isSearching: isSearching)
        }
    }
}

#Preview {
    SearchView()
}
