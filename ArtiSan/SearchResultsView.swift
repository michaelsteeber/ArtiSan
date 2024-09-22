//
//  SearchResultsView.swift
//  ArtiSan
//
//  Created by Michael Steeber on 9/22/24.
//

import SwiftUI

struct SearchResultsView: View {
    @Environment(\.openWindow) var openWindow
    @Binding var searchResults: [Album]?
    
    var body: some View {
        if let searchResults {
            if searchResults.isEmpty {
                    ContentUnavailableView("No Results", systemImage: "square.3.layers.3d.down.right.slash")
                        .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(searchResults, id: \.self) { result in
                            Button {
                                openWindow(value: result)
                            } label: {
                                VStack {
                                    AsyncImage(url: result.image(.thumbnail)) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(1.0, contentMode: .fit)
                                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    } placeholder: {
                                        PlaceHolderView()
                                            .aspectRatio(1.0, contentMode: .fit)
                                    }
                                    
                                    Text(result.collectionName)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(1)
                                        .font(.callout)
                                    Text(result.artistName)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(1)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 15)
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 15))
                }
                .frame(maxHeight: .infinity)
            }
        } else {
            ContentUnavailableView("Artisan", systemImage: "square.stack.3d.down.right")
                .frame(maxHeight: .infinity)
        }
    }
}

struct iTunesResponse: Codable {
    let resultCount: Int
    let results: [Album]
}

struct Album: Codable, Hashable {
    let wrapperType: String
    let collectionType: String
    let artistId: Int?
    let collectionId: Int
    let amgArtistId: Int?
    let artistName: String
    let collectionName: String
    let collectionCensoredName: String?
    
    let artistViewUrl: URL?
    let collectionViewUrl: URL?
    let artworkUrl60: URL
    let artworkUrl100: URL
    
    let collectionPrice: Double?
    let collectionExplicitness: String?
    let contentAdvisoryRating: String?
    let trackCount: Int?
    let copyright: String?
    let country: String?
    let currency: String?
    let releaseDate: String?
    let primaryGenreName: String?
    
    enum Resolution {
        case thumbnail, preview, full
    }
    
    func image(_ resolution: Resolution) -> URL {
        let dimensions: String
        switch resolution {
        case .thumbnail:
            dimensions = "400x400"
        case .preview:
            dimensions = "1200x1200"
        case .full:
            dimensions = "6000x6000"
        }
        let urlString = artworkUrl100.absoluteString
        let transformed = urlString.replacingOccurrences(of: "100x100bb", with: dimensions)
        return URL(string: transformed)!
    }
    
    static let fallback = Album(
            wrapperType: "collection",
            collectionType: "Album",
            artistId: nil,
            collectionId: 1497230760,
            amgArtistId: nil,
            artistName: "Tame Impala",
            collectionName: "The Slow Rush",
            collectionCensoredName: nil,
            artistViewUrl: nil,
            collectionViewUrl: nil,
            artworkUrl60: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/65/e3/e7/65e3e740-b69f-f5cb-f2e6-7dedb5265ac9/19UMGIM96748.rgb.jpg/60x60bb.jpg")!,
            artworkUrl100: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/65/e3/e7/65e3e740-b69f-f5cb-f2e6-7dedb5265ac9/19UMGIM96748.rgb.jpg/100x100bb.jpg")!,
            collectionPrice: nil,
            collectionExplicitness: nil,
            contentAdvisoryRating: nil,
            trackCount: nil,
            copyright: nil,
            country: nil,
            currency: nil,
            releaseDate: nil,
            primaryGenreName: nil
        )
}

#Preview {
    SearchResultsView(searchResults: .constant([]))
}
