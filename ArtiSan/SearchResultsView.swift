//
//  SearchResultsView.swift
//  ArtiSan
//
//  Created by Michael Steeber on 9/22/24.
//

import SwiftUI

/// A ScrollView with all results returned from the iTunes Search API. If there are no results or the app is searching, placeholder content is shown.
struct SearchResultsView: View {
    @Environment(\.openWindow) var openWindow
    @Binding var searchResults: [Album]?
    var isSearching: Bool
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        if let searchResults {
            if searchResults.isEmpty {
                    ContentUnavailableView("No Results", systemImage: "square.3.layers.3d.down.right.slash")
                        .frame(maxHeight: .infinity)
                        .symbolEffect(.pulse, options: .speed(1.5), isActive: isSearching)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(searchResults, id: \.self) { result in
                            Button {
                                openWindow(value: result)
                            } label: {
                                ResultView(result: result)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 5)
                        }
                    }
                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 15, trailing: 15))
                }
                .frame(maxHeight: .infinity)
                .scrollClipDisabled()
            }
        } else {
            Image(systemName: "music.quarternote.3")
                .font(Font.system(size: 60))
                .padding()
                .foregroundStyle(.placeholder)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .symbolEffect(.pulse, options: .speed(1.5), isActive: isSearching)
        }
    }
}

/// A single seearch result.
struct ResultView: View {
    @State private var isHovering = false
    @State private var isDownloading = false
    let result: Album
    let curator = Curator()
    
    var body: some View {
        VStack {
            AsyncImage(url: result.image(.thumbnail), transaction: Transaction(animation: .easeInOut(duration: 0.5))) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .transition(.opacity)
                default:
                    PlaceHolderView()
                        .aspectRatio(1.0, contentMode: .fit)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(.primary.opacity(0.1), lineWidth: 1)
            }
            
            HStack {
                VStack {
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
                if isHovering {
                    Button {
                        Task {
                            isDownloading = true
                            if let image = await curator.downloadImage(from: result.image(.full))?.0 {
                                isDownloading = false
                                let name = curator.getImageFileName(from: image, with: result.collectionName)
                                if let url = curator.savePanel(name: name) {
                                    Task { await curator.saveImage(image: image, path: url) }
                                }
                            }
                        }
                    } label: {
                        if isDownloading {
                            ProgressView()
                                .controlSize(.small)
                                .foregroundStyle(.secondary)
                        } else {
                            Image(systemName: "arrow.down.circle")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 0))
                        }
                    }
                    .transition(.opacity)
                    .accessibilityLabel("Download Image")
                    .buttonStyle(.borderless)
                }
            }
        }
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.2)) { isHovering = hover }
        }
    }
}

#Preview {
    SearchResultsView(searchResults: .constant([]), isSearching: false)
}
