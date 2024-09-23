//
//  ImageView.swift
//  ArtiSan
//
//  Created by Michael Steeber on 9/3/24.
//

import SwiftUI

/// A large image viewer for high quality album art.
struct ImageView: View {
    @State private var isHovering = false
    @State private var appeared = false
    @State private var images: (NSImage, Image)?
    @State private var isDownloaded = false
    let album: Album
    let curator = Curator()
    
    var body: some View {
        VStack {
            if isDownloaded {
                if let image = images?.1 {
                    image
                        .resizable()
                }
            } else {
                PlaceHolderView()
            }
        }
        .transition(.opacity)
        .ignoresSafeArea(.all)
        .onHover { hover in
            isHovering = hover
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { appeared = true }
            }
            Task { images = await curator.downloadImage(from: album.image(.full)) }
        }
        .overlay(alignment: .bottom) {
            if appeared {
                AlbumArtOverlay()
            }
        }
        .onChange(of: images?.0) {
            withAnimation(.easeInOut(duration: 0.5)) { isDownloaded = true }
        }
    }
    
    /// The overlay along the bottom edge of the album art.
    @ViewBuilder
    func AlbumArtOverlay() -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(album.collectionName)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(album.artistName)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .lineLimit(1)
            Button {
                let name = curator.getImageFileName(from: images?.0, with: album.collectionName)
                if let url = curator.savePanel(name: name) {
                    Task { await curator.saveImage(image: images?.0, path: url) }
                }
            } label: {
                Image(systemName: "arrow.down.circle")
                    .font(.largeTitle.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Download Image")
            .buttonStyle(.borderless)
        }
        .transition(.push(from: .bottom))
        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
        .background(.ultraThinMaterial)
        .opacity(isHovering ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.2), value: isHovering)
        .disabled(!isHovering)
        .focusEffectDisabled()
        .onHover { hover in
            isHovering = hover
        }
    }
}

#Preview {
    ImageView(album: Album.fallback)
        .frame(width: 600, height: 600)
}
