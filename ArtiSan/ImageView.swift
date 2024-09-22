//
//  ImageView.swift
//  ArtiSan
//
//  Created by Michael Steeber on 9/3/24.
//

import SwiftUI

struct ImageView: View {
    @State private var isHovering = false
    @State private var appeared = false
    let album: Album
    
    var body: some View {
        AsyncImage(url: album.image(.preview)) { image in
            image
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        } placeholder: {
            PlaceHolderView()
        }
        .ignoresSafeArea(.all)
        .onHover { hover in
            isHovering = hover
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { appeared = true }
            }
            print(album.image(.full))
        }
        .overlay(alignment: .bottom) {
            if appeared {
                HStack {
                    VStack(alignment: .leading) {
                        Text(album.collectionName)
                            .font(.title3.bold())
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(album.artistName)
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .lineLimit(1)
                }
                .transition(.push(from: .bottom))
                .padding(.all, 10)
                .background(.ultraThinMaterial)
                .disabled(!isHovering)
                .opacity(isHovering ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.2), value: isHovering)
            }
        }
    }
    
    func downloadImage(from url: URL) async -> Image? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            guard let nsImage = NSImage(data: data) else { return nil }
            let image = Image(nsImage: nsImage)
            return image
        } catch {
            return nil
        }
    }
}

#Preview {
    ImageView(album: Album.fallback)
        .frame(width: 600, height: 600)
}
