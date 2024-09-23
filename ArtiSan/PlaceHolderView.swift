//
//  PlaceHolderView.swift
//  ArtiSan
//
//  Created by Michael Steeber on 9/3/24.
//

import SwiftUI

/// A reusable placeholder view that animates while an image is loading.
struct PlaceHolderView: View {
    var body: some View {
        Color.secondary.opacity(0.15)
            .frame(maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                Image(systemName: "music.quarternote.3")
                    .font(Font.system(size: 60))
                    .padding()
                    .symbolEffect(.pulse, options: .speed(1.5), isActive: true)
                    .foregroundStyle(.placeholder)
            }
    }
}

#Preview {
    PlaceHolderView()
}
